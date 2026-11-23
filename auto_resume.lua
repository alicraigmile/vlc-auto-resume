local state_file = os.getenv("HOME") .. "/.local/share/vlc/last_played.txt"
local last_saved_block = ""

local function sleep_us(us)
    local ok = pcall(vlc.misc.mwait, vlc.misc.mdate() + us)
    return ok
end

local function format_time(sec)
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    if h > 0 then
        return string.format("%d:%02d:%02d", h, m, s)
    end
    return string.format("%02d:%02d", m, s)
end

local function fallback_name_from_uri(uri)
    local tail = uri:match("([^/]+)$") or uri
    tail = tail:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
    return tail
end

local function read_last_state()
    local f = io.open(state_file, "r")
    if not f then return nil, 0, "" end
    local uri = f:read("*l")
    local pos = tonumber(f:read("*l")) or 0
    local title = f:read("*l") or ""
    f:close()
    if uri and uri ~= "" then
        if title == "" then title = fallback_name_from_uri(uri) end
        return uri, pos, title
    end
    return nil, 0, ""
end

local function write_last_state(uri, pos, title)
    if not uri or uri == "" then return end
    local clean_title = (title and title ~= "") and title:gsub("[\r\n]", " ") or fallback_name_from_uri(uri)
    local block = uri .. "\n" .. tostring(pos) .. "\n" .. clean_title
    if block == last_saved_block then return end

    local f = io.open(state_file, "w")
    if not f then return end
    f:write(block .. "\n")
    f:close()
    last_saved_block = block
end

local function get_active_media()
    local uri = nil
    local title = nil

    local inp = vlc.input.item()
    if inp then
        local u = inp:uri()
        if u and u ~= "" then uri = u end
        local n = inp:name()
        if n and n ~= "" then title = n end
    end

    local cur_pl = vlc.playlist.get("normal", false)
    if cur_pl and cur_pl.children then
        for _, item in ipairs(cur_pl.children) do
            local candidate = item.path or item.uri
            if item.current and candidate and candidate ~= "" then
                uri = uri or candidate
                if (not title or title == "" or title == uri) and item.name and item.name ~= "" then
                    title = item.name
                end
                break
            end
        end
        if not uri and #cur_pl.children == 1 then
            local only = cur_pl.children[1]
            local candidate = only.path or only.uri
            if candidate and candidate ~= "" then
                uri = candidate
                if (not title or title == "" or title == uri) and only.name and only.name ~= "" then
                    title = only.name
                end
            end
        end
    end

    return uri, title
end

local function get_current_seconds()
    local input_obj = vlc.object.input()
    if not input_obj then return 0 end
    local t = vlc.var.get(input_obj, "time")
    if not t then return 0 end
    if t > 1000000 then
        return math.floor(t / 1000000)
    end
    return math.floor(t)
end

local function shell_escape(str)
    return "'" .. tostring(str):gsub("'", "'\\''") .. "'"
end

local function xml_escape(str)
    return tostring(str)
        :gsub("&", "&amp;")
        :gsub("<", "&lt;")
        :gsub(">", "&gt;")
end

local function ask_continue(uri, pos, title)
    local ts = format_time(pos)
    local continue_label = "Continue at " .. ts
    local restart_label = "Play from the start"

    local zenity_msg = "<b>" .. xml_escape(title) .. "</b>\n" .. xml_escape(uri)
    local kdialog_msg = title .. "\n\n" .. uri

    local esc_zmsg = shell_escape(zenity_msg)
    local esc_kmsg = shell_escape(kdialog_msg)
    local esc_cont = shell_escape(continue_label)
    local esc_rest = shell_escape(restart_label)

    local cmd = string.format(
        "if command -v zenity >/dev/null 2>&1; then " ..
        "out=$(zenity --question --title='Continue playback' --width=450 " ..
        "--ok-label=%s --extra-button=%s --cancel-label='Cancel' --text=%s 2>/dev/null); " ..
        "rc=$?; " ..
        "case \"$out\" in *'Play from the start'*) echo 'restart' ;; *) " ..
        "if [ $rc -eq 0 ]; then echo 'continue'; else echo 'cancel'; fi ;; esac; " ..
        "elif command -v kdialog >/dev/null 2>&1; then " ..
        "kdialog --title 'Continue playback' --yes-label=%s --no-label=%s --cancel-label='Cancel' --yesnocancel %s >/dev/null 2>&1; " ..
        "rc=$?; " ..
        "if [ $rc -eq 0 ]; then echo 'continue'; " ..
        "elif [ $rc -eq 1 ]; then echo 'restart'; " ..
        "else echo 'cancel'; fi; " ..
        "else echo 'continue'; fi",
        esc_cont, esc_rest, esc_zmsg,
        esc_cont, esc_rest, esc_kmsg
    )

    local pipe = io.popen(cmd)
    if not pipe then return "cancel" end
    local choice = pipe:read("*l") or "cancel"
    pipe:close()
    return choice
end

-- Wait 500ms so any CLI/file-manager file loads first
if not sleep_us(500000) then return end

local pl = vlc.playlist.get("normal", false)
local count = (pl and pl.children) and #pl.children or 0
local force_restart = false

if count == 0 then
    local last_uri, last_pos, last_title = read_last_state()
    if last_uri then
        last_saved_block = last_uri .. "\n" .. tostring(last_pos) .. "\n" .. last_title
        local choice = ask_continue(last_uri, last_pos, last_title)

        if choice == "continue" then
            local item = { path = last_uri, name = last_title }
            if last_pos > 2 then
                item.options = { "start-time=" .. tostring(last_pos) }
            end
            vlc.playlist.add({ item })
        elseif choice == "restart" then
            force_restart = true
            vlc.playlist.add({ { path = last_uri, name = last_title, options = { "start-time=0" } } })
        end
    end
end

while sleep_us(1000000) do
    local uri, title = get_active_media()
    if uri then
        if force_restart then
            local input_obj = vlc.object.input()
            if input_obj then
                vlc.var.set(input_obj, "time", 0)
                force_restart = false
            end
        end
        local pos = get_current_seconds()
        write_last_state(uri, pos, title)
    end
end
