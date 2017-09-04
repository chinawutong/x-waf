#!/bin/sh

    lua_package_path "/usr/local/openresty/nginx/conf/x-waf/?.lua;/usr/local/lib/lua/?.lua;;";
    lua_shared_dict limit 100m;
    lua_shared_dict badGuys 100m;
    # cache for lua
    lua_code_cache on;

    init_by_lua_file /usr/local/openresty/nginx/conf/x-waf/init.lua;
    access_by_lua_file /usr/local/openresty/nginx/conf/x-waf/access.lua;
