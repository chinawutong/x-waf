--

local chunk = ngx.arg[1]
--local preurl = ngx.var["cookie_preurl"]

if string.match( chunk, "success" ) then
    return ngx.redirect(baidu.com)
else
    return true
end
if string.match( chunk, "wrong") then
    ngx.header.content_type = "text/html"
    ngx.print("hello")
    --ngx.print(string.format(config.config_captcha_html))
    ngx.exit(200)
else
    return true
end