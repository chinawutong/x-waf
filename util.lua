--[[

Copyright (c) 2016 xsec.io

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THEq
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local io = require("io")
local cjson = require("cjson.safe")
local string = require("string")
local config = require("config")

local util = {
    version = "0.1",
    RULE_TABLE = {},
    RULE_FILES = {
        "args.rule",
        "blackip.rule",
        "cookie.rule",
        "post.rule",
        "url.rule",
        "useragent.rule",
        "whiteip.rule",
        "whiteUrl.rule"
    }
}

-- Get all rule file name
function util.get_rule_files(rules_path)
    local rule_files = {}
    for _, file in ipairs(util.RULE_FILES) do
        if file ~= "" then
            local file_name = rules_path .. '/' .. file
            ngx.log(ngx.DEBUG, string.format("rule key:%s, rule file name:%s", file, file_name))
            rule_files[file] = file_name
        end
    end
    return rule_files
end


-- Load WAF rules into table when on nginx's init phase
function util.get_rules(rules_path)
    local rule_files = util.get_rule_files(rules_path)
    if rule_files == {} then
        return nil
    end

    for rule_name, rule_file in pairs(rule_files) do
        local t_rule = {}
        local file_rule_name = io.open(rule_file)
        local json_rules = file_rule_name:read("*a")
        file_rule_name:close()
        local table_rules = cjson.decode(json_rules)
        if table_rules ~= nil then
            ngx.log(ngx.INFO, string.format("%s:%s", table_rules, type(table_rules)))
            for _, table_name in pairs(table_rules) do
                -- ngx.log(ngx.INFO, string.format("Insert table:%s, value:%s", t_rule, table_name["RuleItem"]))
                table.insert(t_rule, table_name["RuleItem"])
            end
        end
        ngx.log(ngx.INFO, string.format("rule_name:%s, value:%s", rule_name, t_rule))
        util.RULE_TABLE[rule_name] = t_rule
    end
    return(util.RULE_TABLE)
end

-- Get the client IP
function util.get_client_ip()
    local CLIENT_IP = ngx.req.get_headers()["X_real_ip"]
    if CLIENT_IP == nil then
        CLIENT_IP = ngx.req.get_headers()["X_Forwarded_For"]
    end
    if CLIENT_IP == nil then
        CLIENT_IP  = ngx.var.remote_addr
    end
    if CLIENT_IP == nil then
        CLIENT_IP  = ""
    end
    return CLIENT_IP
end

-- Get the client user agent
function util.get_user_agent()
    local USER_AGENT = ngx.var.http_user_agent
    if USER_AGENT == nil then
        USER_AGENT = "unknown"
    end
    return USER_AGENT
end
-- get server's host
function util.get_server_host()
    local host = ngx.req.get_headers()["Host"]
    return host
end

-- Get all rule file name by lfs
--function util.get_rule_files(rules_path)
--local lfs = require("lfs")
--    local rule_files = {}
--    for file in lfs.dir(rules_path) do
--        if file ~= "." and file ~= ".." then
--            local file_name = rules_path .. '/' .. file
--            ngx.log(ngx.DEBUG, string.format("rule key:%s, rule file name:%s", file, file_name))
--            rule_files[file] = file_name
--        end
--    end
--    return rule_files
--end

-- WAF log record for json
function util.log_record(config_log_dir, method, url, data, ruletag)
    local log_path = config_log_dir..'/'..method
    local client_IP = util.get_client_ip()
    local user_agent = util.get_user_agent()
    local server_name = ngx.var.server_name
    local local_time = ngx.localtime()
    local log_json_obj = {
        client_ip = client_IP,
        local_time = local_time,
        server_name = server_name,
        user_agent = user_agent,
        attackutilethod = method,
        req_url = url,
        req_data = data,
        rule_tag = ruletag,
    }
    local file_path = io.open(log_path, "rb")
    if file_path then
        file_path:close()
    else
        os.execute('mkdir -p '..log_path)
    end
    
    local log_line = cjson.encode(log_json_obj)
    local log_name = string.format("%s/%s_waf.log", log_path, ngx.today())
    
    local file,err = io.open(log_name, "a+")
    if err ~= nil then ngx.log(ngx.DEBUG, "file err:"..err) end
    if file == nil then
        return
    end

    file:write(string.format("%s\n", log_line))
    file:flush()
    file:close()
end

-- WAF response
function util.waf_output()
    if config.config_wafutilodel == "redirect" then
        ngx.redirect(config.config_waf_redirect_url, 301)
    elseif config.config_wafutilodel == "jinghuashuiyue" then
        local bad_guy_ip = util.get_client_ip()
        util.set_bad_guys(bad_guy_ip, config.config_expire_time)
    else
        ngx.header.content_type = "text/html"
        ngx.status = ngx.HTTP_FORBIDDEN
        ngx.say(string.format(config.config_output_html, util.get_client_ip()))
        ngx.exit(ngx.status)
    end
end

-- set bad guys ip to ngx.shared dict
function util.set_bad_guys(bad_guy_ip, expire_time)
    local badGuys = ngx.shared.badGuys
    local req, _ = badGuys:get(bad_guy_ip)
    if req then
        badGuys:incr(bad_guy_ip, 1)
    else
        badGuys:set(bad_guy_ip, 1, expire_time)
    end
end

-- others....

return util
