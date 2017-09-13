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

-- WAF config file, enable = "on", disable = "off"

local base_dir = "/usr/local/openresty"

local config = {
    -- base dir
    config_base_dir = base_dir,
    -- waf status
    config_waf_enable = "on",
    -- log dir
    config_log_dir = "/tmp/waf_logs",
    -- rule setting
    config_rule_dir = base_dir.."/nginx/conf/x-waf/rules",
    -- captchapage
    config_captchapage = base_dir.."/nginx/html/captcha.html",
    -- enable/disable white url
    config_white_url_check = "on",
    -- enable/disable white ip
    config_white_ip_check = "on",
    -- enable/disable block ip
    config_black_ip_check = "on",
    -- enable/disable url filtering
    config_url_check = "on",
    -- enalbe/disable url args filtering
    config_url_args_check = "on",
    -- enable/disable user agent filtering
    config_user_agent_check = "on",
    -- enable/disable cookie deny filtering
    config_cookie_check = "on",
    -- enable/disable cc filtering
    config_cc_check = "on",
    -- cc rate the xxx of xxx seconds
    config_cc_rate = "10/60",
    -- enable/disable post filtering
    config_post_check = "on",
    -- config waf output redirect/html/jinghuashuiyue
    config_waf_model = "html",
    -- if config_waf_output ,setting url
    config_waf_redirect_url = "",

    config_expire_time = 600,

    config_output_html=[[
    <html>
    <head>
    <meta charset="UTF-8">
    <title>xsec waf</title>
    <style type="text/css">
        body {
      font-family: "Helvetica Neue", Helvetica, Arial;
      font-size: 14px;
      line-height: 20px;
      font-weight: 400;
      color: #3b3b3b;
      -webkit-font-smoothing: antialiased;
      font-smoothing: antialiased;
      background: #f6f6f6;
    }
    .wrapper {
      margin: 0 auto;
      padding: 40px;
      max-width: 980px;
    }
    .table {
      margin: 0 0 40px 0;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
      display: table;
    }
    @media screen and (max-width: 580px) {
      .table {
        display: block;
      }
    }
    .row {
      display: table-row;
      background: #f6f6f6;
    }
    .row:nth-of-type(odd) {
      background: #e9e9e9;
    }
    .row.header {
      font-weight: 900;
      color: #ffffff;
      background: #ea6153;
    }
    .row.green {
      background: #27ae60;
    }
    .row.yellow {
      background: #FF8C00;
    }
    @media screen and (max-width: 580px) {
      .row {
        padding: 8px 0;
        display: block;
      }
    }
    .cell {
      padding: 6px 12px;
      display: table-cell;
    }
    @media screen and (max-width: 580px) {
      .cell {
        padding: 2px 12px;
        display: block;
      }
    }
    </style>
    </head>
      <body>
        <div class="wrapper">
      <div class="table">
        <div class="row header yellow">
          <div class="cell">
            您的IP为 %s
          </div>
          <div class="cell">
            欢迎在遵守白帽子道德准则的情况下进行安全测试。
          </div>
          <div class="cell">
            联系方式：x@xsec.io
          </div>
        </div>
      </div>
    </div>
      </body>
    </html>
    ]],
    config_captcha_html=[[
    <html>
      <head>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8">
        <title>请输入验证码</title>
        <style>
          body { font-family: Tahoma, Verdana, Arial, sans-serif; } 
			    .head_title{ margin-top:100px; font-family:"微软雅黑"; font-size:50px; font-weight:lighter;}	
			    p{font-family:"微软雅黑"; font-size:16px; font-weight:lighter; color:#666666;}
			    .btn{ float:left;margin-left:15px; margin-top:5px; width:85px; height:30px; background:#56c458;font-family:"微软雅黑"; font-size:16px; color:#FFFFFF; border:0;}
			    .inp_s{ float:left; margin-left:15px; margin-top:5px; width:200px; height:30px;}
			    .yz{float:left; margin-top:5px; width:70px; height:30px;}
			    .fors{ margin:0 auto;width:500px; height:40px;}
		    </style>
      </head>
      <body>
        <div align="center">
		      <p><h1 class="head_title">很抱歉...</h1></p>
		      <p>您的查询看起来类似于来自计算机软件的自动请求。为了保护我们的用户，请原谅我们现在暂时不能处理您的请求。 </p>
		      <p>要继续访问网页，请输入下面所示字符：</p>
          <form class="fors" action="/verifycap" method="POST">
            <img class="yz" src="http://192.168.0.7/Ashx/System/VaidCode.ashx" onclick="this.src='http://192.168.0.7/Ashx/System/VaidCode.ashx?flag='+Math.random()" alt="Captcha image"><input class="inp_s" type="text" name="code" /><input class="inp_s" type="text" name="type" value="check" style="display:none;" /><input class="btn" type="submit" value="确定" />
          </form>
        </div>
      </body>
    </html>
    ]],
}

return config
