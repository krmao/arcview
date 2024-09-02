### [发布](https://ohpm.openharmony.cn/#/cn/help/createandpublish)

- [认证管理](https://ohpm.openharmony.cn/#/cn/help/certifymanage)
    - `ssh-keygen -m PEM -t RSA -b 4096 -f ~/.ssh_ohpm/mykey`
    - `ohpm config set key_path ~/.ssh_ohpm/mykey`
- `ohpm config set publish_id your_publish_id`
- `ohpm publish <HAR路径>`
    - DevEco Studio -> Build -> Clean Project
    - click module 'library' -> Build -> Make module 'library'
- `ohpm publish ./library.har`
    - `cd ~/workspace/arkview/library/build/default/outputs/default/`
- [查看审核进度](https://ohpm.openharmony.cn/#/cn/personalCenter/package)