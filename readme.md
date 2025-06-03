### Description

* 本项目包含两部分代码
  * `aws terraform`代码，位于`infra`目录下
  * `php laravel`代码，位于`laravel-webapp`目录下

* 本地运行demo演示:
  ```
  cd laravel-webapp && docker compose -f docker-compose.yaml up
  ```

* 修改`main`分支以下目录中的内容将会触发pipeline，并且pipeline成功或者失败都会发送相应邮件到接收人
    * `.github/workflows`
    * `laravel-webapp`
