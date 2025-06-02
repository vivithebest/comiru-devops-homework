### Description

* 本项目包含两部分代码，

  * 一个aws terraform代码，位于infra下
  * 一个php laravel-webapp代码，位于laravel-webapp下
* 本地运行demo演示:

  ```
  cd laravel-webapp && docker compose -f docker-compose.yaml up
  ```
* 修改 `main`分支 `.github/workflows`下或者 `laravel-webapp`下的代码将会触发pipeline，pipeline成功或者失败都会发送相应邮件到接收人
