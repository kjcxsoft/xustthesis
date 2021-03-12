# 西安科技大学学位论文 LaTeX 模板

本项目是西安科技大学的学位论文 LaTeX 模板 xustthesis，基于 [中国科学技术大学学位论文 LaTeX 模板](https://github.com/ustctug/ustcthesis) **v3.2.1** 修改，原中科大模板按照最新版的
《[研究生学位论文撰写手册](http://gradschool.ustc.edu.cn/ylb/material/xw/wdxz/32.pdf)》
和
《[关于本科毕业论文（设计）格式和统一封面的通知](http://www.teach.ustc.edu.cn/document/doc-administration/4032.html)》
的要求编写，本模板尽可能遵循西科大论文编写要求修改，兼容最新版的 TeX Live、MacTeX 、MiKTeX 发行版，支持跨平台使用。

注意：

1. 使用说明文档 `ustcthesis-doc.pdf` 在发布版中附带，用户也可自行编译；**使用模板前应仔细阅读**。

2. 本模板要求 TeX Live、MacTeX、MiKTeX 不低于 2017 年的发行版，
并且尽可能升级到最新。安装和升级方法见
[新手指南](https://github.com/ustctug/ustcthesis/wiki/新手指南)。

3. **不支持** [CTeX 套装](https://github.com/ustctug/ustcthesis/wiki/常见问题#3-模板支持用-ctex-套装编译吗)。

4. 由于继承自 ustcthesis，项目中存在大量 **ustc** 名称空间的命令、变量等，或直接将原项目中 *ustc* 修改为 *xust*


## 致谢
本项目大量继承自上游 **中科大论文模板**，首先十分感谢上游各位的贡献

由于个人技术原因并没有为上游贡献，希望有能力的小伙伴可以改进此项目并多为上游做贡献，如果上游有要求可以遵从要求移除本项目或转为私有


## 编译文档

- 编译模板的使用说明文档 `ustcthesis-doc.pdf`：
   ```
   latexmk -xelatex ustcthesis-doc.tex
   ```
- 编译论文 `main.pdf`：
   ```
   latexmk -xelatex main.tex
   ```
- 如需清理论文编译过程中的临时文件，可以：
   ```
   latexmk -c
   ```

- 以上编译过程也可以用 `make` 工具：
   ```
   make doc        # 编译生成 ustcthesis-doc.pdf
   make            # 编译生成论文 main.pdf
   make clean      # 删除编译过程中生成的临时文件
   ```

## 反馈问题

如果发现模板有问题，请按照以下步骤操作：

1. 阅读学校的标准，判断是否符合学校的要求；
2. 阅读 [常见问题 FAQ](https://github.com/ustctug/ustcthesis/wiki/常见问题)；
3. 将 TeX 发行版和宏包升级到最新，并且将模板升级到 Github 上最新版本，
查看问题是否已经修复；
4. 在 [GitHub Issues (xustthesis)](https://github.com/GinShio/xustthesis/issues) 或 [GitHub Issues (ustcthesis)](https://github.com/ustctug/ustcthesis/issues)
中搜索该问题的关键词；
5. 在 [GitHub Issues (xustthesis)](https://github.com/GinShio/xustthesis/issues)
中提出新 issue，并回答以下问题：
    - 使用了什么版本的 TeX Live / MacTeX / MiKTeX ？
    - 具体的问题是什么？
    - 正确的结果应该是什么样的？
    - 是否应该附上相关源码或者截图？

如果导师或者院系在格式上有额外的要求，请将老师的邮件转发给模板作者。
作者会考虑增加接口以便修改格式。


## 更多资料

- [LaTeX 新手入门指南](https://github.com/ustctug/ustcthesis/wiki/新手指南)
- [常见问题 FAQ](https://github.com/ustctug/ustcthesis/wiki/常见问题)
- [参与开发](https://github.com/ustctug/ustcthesis/wiki/参与开发)


## LICENSE
[LPPL-1.3c License](https://github.com/ustctug/ustcthesis/blob/master/LICENSE) © [ustctug/ustcthesis](https://github.com/ustctug/ustcthesis)

[LPPL-1.3c License](LICENSE) © [GinShio/xustthesis](https://github.com/GinShio/xustthesis)

## XUST 版权
目录 xust 下的所有内容，版权归 XUST 所有，本项目不享有 xust 相关内容的所有版权
