# AntSword-NixOS
在NixOS上跑蚁剑喵

## 分享一下自己的心路历程

众所周知NixOS是一个非常奇特的操作系统，为了在NixOS上运行正常的程序我们需要用特殊的方式打包程序让程序可以正常识别动态链接库。。。。

还是直接开始吧喵，众所周知蚁剑基于electron 4,而electron 4早就过时了，为了在NixOS上跑蚁剑我们需要动态patch蚁剑的loader,这样才能在Nixos上运行蚁剑

但是！！！事情根本没有这么简单！！！蚁剑除了会使用动态链接库之外还会在软件的根目录的`resource/`文件夹写一个文件，但是NixOS会把蚁剑安装到一个只读的文件夹里，导致蚁剑无法运行！！

所以我们还需要动态修改蚁剑的JS代码，让蚁剑不要往那里写文件。。。

对应的JS代码在那些`.asar`文件里（貌似是叫这个名字吧），然后这个文件里不仅保存了对应的JS代码，还保存了JS代码的长度！！因为他记录了JS代码的长度我们不能随便改JS代码，只能在保持JS代码长度不变的情况下一个一个字符的改！！！

构建代码我已经写好了喵，在`default.nix`里，不会用？那就看看下一节

## 怎么使用

把这个`default.nix`复制到`/etc/nixos`里，然后在`configuration.nix`指定安装软件的那个列表里加上这么一行：`pkgs.callPackage ./default.nix {}`

这样就好了，这个`pkgs.callPackage ./default.nix {}`代表的是和`pkgs.firefox`一样的软件包derivation，直接替换就好了

## 为什么不传上nixpkgs

懒喵
