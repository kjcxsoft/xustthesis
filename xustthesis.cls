\NeedsTeXFormat{LaTeX2e}[2017/04/15]
\ProvidesClass{xustthesis}[2021/03/11 v0.1.0 XUST thesis template]

% 报错和警告
\newcommand\xust@error[1]{%
  \ClassError{xustthesis}{#1}{}%
}
\newcommand\xust@warning[1]{%
  \ClassWarning{xustthesis}{#1}%
}

% 检查 \LaTeXe{} kernel 版本
\@ifl@t@r\fmtversion{2017/04/15}{}{
  \xust@error{%
    TeX Live 2017 or later version is required to compile this document%
  }
}

% 检查编译引擎，要求使用 XeLaTeX。
\RequirePackage{iftex}
\ifXeTeX\else
  \xust@error{XeLaTeX is required to compile this document}
\fi


% \subsection{处理选项}

\RequirePackage{kvdefinekeys}
\RequirePackage{kvsetkeys}
\RequirePackage{kvoptions}

% 提供一个 \cs{xustsetup} 命令支持 \emph{key-value} 的方式来设置，修改自原模板 \cs{ustcsetup}
\let\xust@setup@hook\@empty
\newcommand\xustsetup[1]{%
  \let\xust@setup@hook\@empty
  \kvsetkeys{xust}{#1}%
  \xust@setup@hook
}

% 同时用 \emph{key-value} 的方式来定义这些接口：
% \begin{latex}
%   \xust@define@key{
%     <key> = {
%       name = <name>,
%       choices = {
%         <choice1>,
%         <choice2>,
%       },
%       default = <default>,
%       code = <code>,
%     },
%   }
% \end{latex}

% 其中 |choices| 设置允许使用的值，默认为第一个（或者 \meta{default}）；
% \meta{code} 是相应的内容被设置时执行的代码。

\newcommand\xust@define@key[1]{%
  \kvsetkeys{xust@key}{#1}%
}
\kv@set@family@handler{xust@key}{%
%
% \cs{xustsetup} 会将 \meta{value} 存到 \cs{xust@\meta{key}}，
% 但是宏的名字包含 “-” 这样的特殊字符时不方便直接调用，比如 |key = math-style|，
% 这时可以用 |name| 设置 \meta{key} 的别称，比如 |key = math@style|，
% 这样就可以通过 \cs{xust@math@style} 来引用。
% |default| 是定义该 \meta{key} 时默认的值，缺省为空。
%
  \@namedef{xust@#1@@name}{#1}%
  \def\xust@@default{}%
  \def\xust@@choices{}%
  \kv@define@key{xust@value}{name}{%
    \@namedef{xust@#1@@name}{##1}%
  }%
  %
  % 由于在定义接口时，\cs{xust@\meta{key}@@code} 不一定有定义，
  % 而且在文档类/宏包中还有可能对该 |key| 的 |code| 进行添加。
  % 所以 \cs{xust@\meta{key}@@code} 会检查如果在定义文档类/宏包时则推迟执行，否则立即执行。
  %
  \@namedef{xust@#1@@check}{}%
  \@namedef{xust@#1@@code}{}%
  %
  % 保存下 |choices = {}| 定义的内容，在定义 \cs{xust@\meta{name}} 后再执行。
  %
  \kv@define@key{xust@value}{choices}{%
    \def\xust@@choices{##1}%
    \@namedef{xust@#1@@reset}{}%
    %
    % \cs{xust@\meta{key}@check} 检查 |value| 是否有效，
    % 并设置 \cs{ifxust@\meta{name}@\meta{value}}。
    %
    \@namedef{xust@#1@@check}{%
      \@ifundefined{%
        ifxust@\@nameuse{xust@#1@@name}@\@nameuse{xust@\@nameuse{xust@#1@@name}}%
      }{%
        \xust@error{Invalid value "#1 = \@nameuse{xust@\@nameuse{xust@#1@@name}}"}%
      }%
      \@nameuse{xust@#1@@reset}%
      \@nameuse{xust@\@nameuse{xust@#1@@name}@\@nameuse{xust@\@nameuse{xust@#1@@name}}true}%
    }%
  }%
  \kv@define@key{xust@value}{default}{%
    \def\xust@@default{##1}%
  }%
  \kvsetkeys{xust@value}{#2}%
  \@namedef{xust@\@nameuse{xust@#1@@name}}{}%
  %
  % 第一个 \meta{choice} 设为 \meta{default}，
  % 并且对每个 \meta{choice} 定义 \cs{ifxust@\meta{name}@\meta{choice}}。
  %
  \kv@set@family@handler{xust@choice}{%
    \ifx\xust@@default\@empty
      \def\xust@@default{##1}%
    \fi
    \expandafter\newif\csname ifxust@\@nameuse{xust@#1@@name}@##1\endcsname
    \expandafter\g@addto@macro\csname xust@#1@@reset\endcsname{%
      \@nameuse{xust@\@nameuse{xust@#1@@name}@##1false}%
    }%
  }%
  \kvsetkeys@expandafter{xust@choice}{\xust@@choices}%
  %
  % 将 \meta{default} 赋值到 \cs{xust@\meta{name}}，如果非空则执行相应的代码。
  %
  \expandafter\let\csname xust@\@nameuse{xust@#1@@name}\endcsname\xust@@default
  \expandafter\ifx\csname xust@\@nameuse{xust@#1@@name}\endcsname\@empty\else
    \@nameuse{xust@#1@@check}%
  \fi
  %
  % 定义 \cs{xustsetup} 接口。
  %
  \kv@define@key{xust}{#1}{%
    \@namedef{xust@\@nameuse{xust@#1@@name}}{##1}%
    \@nameuse{xust@#1@@check}%
    \@nameuse{xust@#1@@code}%
  }%
}

% 定义接口向 |key| 添加 |code|：

\newcommand\xust@option@hook[2]{%
  \expandafter\g@addto@macro\csname xust@#1@@code\endcsname{#2}%
}

\xust@define@key{
  degree = {
    choices = {
      doctor,
      master,
      bachelor,
    },
    default = doctor,
  },
  degree-type = {
    name = degree@type,
    choices = {
      academic,
      professional,
    },
    default = academic,
  },
  main-language = {
    name = main@language,
    choices = {
      chinese,
      english,
    },
    default = chinese,
  },
  language = {
    choices = {
      chinese,
      english,
    },
    default = chinese,
  },
  fontset = {
    choices = {
      windows,
      mac,
      unix,
      fandol,
      none,
    },
    default = none,
  },
  system = {
    choices = {
      mac,
      unix,
      windows,
      auto,
    },
    default = auto,
  },
  font = {
    choices = {
      times,
      termes,
      xits,
      libertinus,
      lm,
      auto,
      none,
    },
    default = auto,
  },
  cjk-font = {
    name = cjk@font,
    choices = {
      windows,
      mac,
      noto,
      fandol,
      auto,
      none,
    },
    default = auto,
  },
  math-font = {
    name = math@font,
    choices = {
      xits,
      stix,
      libertinus,
      lm,
      none,
    },
    default = xits,
  },
  cite-style = {
    name = cite@style,
    choices = {
      super,
      inline,
      authoryear,
    },
  },
  output = {
    choices = {
      print,
      electronic,
    },
    default = print,
  },
  section-style = {
    name = section@style,
    choices = {
      chinese,
      arabic,
    },
    default = chinese,
  },
  badge-color = {
    name = badge@color,
    choices = {
      green,
      blue,
      red,
      black,
    },
    default = green,
  },
}

\xustsetup{main-language=\xust@language}%
\let\xust@main@language\xust@language
\xust@option@hook{language}{%
  \ifx\@begindocumenthook\@undefined\else
    \xustsetup{main-language=\xust@language}%
    \let\xust@main@language\xust@language
  \fi
}
\newcommand\xust@reset@main@language{%
  \xustsetup{language = \xust@main@language}%
  \let\xust@language\xust@main@language
}

\newif\ifxust@degree@graduate
\newcommand\xust@set@graduate{%
  \ifxust@degree@bachelor
    \xust@degree@graduatefalse
  \else
    \xust@degree@graduatetrue
  \fi
}
\xust@set@graduate
\xust@option@hook{degree}{%
  \xust@set@graduate
}

% 使用 \pkg{kvoptions} 提供的 key-value 接口，
\SetupKeyvalOptions{
  family  = xust,
  prefix  = xust@,
  setkeys = \kvsetkeys,
}

% 兼容旧版本的文档类选项。
% Reserved for compatibility until 2020-07-01.
\DeclareVoidOption{doctor}{\xustsetup{degree=doctor}}
\DeclareVoidOption{master}{\xustsetup{degree=master}}
\DeclareVoidOption{bachelor}{\xustsetup{degree=bachelor}}
\DeclareVoidOption{chinese}{\xustsetup{language=chinese}}
\DeclareVoidOption{english}{\xustsetup{language=english}}
\DeclareVoidOption{academic}{\xustsetup{degree-type=academic}}
\DeclareVoidOption{professional}{\xustsetup{degree-type=professional}}
\DeclareVoidOption{print}{\xustsetup{output=print}}
\DeclareVoidOption{pdf}{\xustsetup{output=electronic}}
\newif\ifxust@legacy@cite@style
\DeclareVoidOption{super}{\xustsetup{cite-style=super}\xust@legacy@cite@styletrue}
\DeclareVoidOption{numbers}{\xustsetup{cite-style=inline}\xust@legacy@cite@styletrue}
\DeclareVoidOption{authoryear}{\xustsetup{cite-style=authoryear}\xust@legacy@cite@styletrue}
\DeclareVoidOption{arabic}{\xustsetup{section-style=arabic}}
\DeclareVoidOption{colorlogo}{\xustsetup{badge-color=green}}
\DeclareVoidOption{bwlogo}{\xustsetup{badge-color=black}}

% 载入 \cls{ctexbook}。
\PassOptionsToClass{openany}{ctexbook}
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{ctexbook}}
\ProcessKeyvalOptions*


% \subsection{加载文档类和宏包}

\ifxust@language@chinese
  \PassOptionsToClass{scheme=chinese}{ctexbook}
\else
  \PassOptionsToClass{scheme=plain}{ctexbook}
\fi
\ifxust@output@electronic
  \PassOptionsToClass{oneside}{book}
\fi
\PassOptionsToPackage{quiet}{xeCJK}

% 载入 \cls{ctexbook} 文档类，注意要求为 2.4.9 或更高的版本。
\LoadClass[UTF8,a4paper,zihao=-4,fontset=none]{ctexbook}[2017/04/01]

% 建议在模板开始处载入全部宏包，不要轻易改变加载顺序。
% \pkg{hyperref} 一般在最后加载。
\RequirePackage{amsmath}
\RequirePackage{fontspec}[2017/03/31]
\RequirePackage{unicode-math}
\RequirePackage[driver=xetex]{geometry}
\RequirePackage{graphicx}
\RequirePackage{fancyhdr}
\RequirePackage{color}
\RequirePackage{titletoc}
\RequirePackage{caption}
\RequirePackage[perpage]{footmisc}
\RequirePackage{url}
\RequirePackage{calc}
\RequirePackage{notoccite}

% 对冲突的宏包报错。
\RequirePackage{filehook}
\newcommand\xust@package@conflict[2]{
  \AtBeginOfPackageFile*{#2}{
    \xust@error{The "#2" package is incompatible with required "#1"}
  }
}

\xust@package@conflict{biblatex}{bibunits}
\xust@package@conflict{biblatex}{chapterbib}
\xust@package@conflict{biblatex}{cite}
\xust@package@conflict{biblatex}{multibib}
\xust@package@conflict{biblatex}{natbib}

\xust@package@conflict{unicode-math}{amscd}
\xust@package@conflict{unicode-math}{amsfonts}
\xust@package@conflict{unicode-math}{amssymb}
\xust@package@conflict{unicode-math}{bbm}
\xust@package@conflict{unicode-math}{bm}
\xust@package@conflict{unicode-math}{eucal}
\xust@package@conflict{unicode-math}{eufrak}
\xust@package@conflict{unicode-math}{mathrsfs}


% \subsection{字体}

% 处理 \opt{fontset}
\ifxust@fontset@mac
  \xustsetup{
    font     = times,
    cjk-font = mac,
  }
\else
  \ifxust@fontset@windows
    \xustsetup{
      font     = times,
      cjk-font = windows,
    }
  \else
    \ifxust@fontset@fandol
      \xustsetup{
        font     = termes,
        cjk-font = fandol,
      }
    \else
      \ifxust@fontset@unix
        \xustsetup{
          font     = termes,
          cjk-font = noto,
        }
      \fi
    \fi
  \fi
\fi

% 检测系统
\ifxust@system@auto
  \IfFileExists{/System/Library/Fonts/Menlo.ttc}{
    \xustsetup{system = mac}
  }{
    \IfFileExists{/dev/null}{
      \IfFileExists{null:}{
        \xustsetup{system = windows}
      }{
        \xustsetup{system = unix}
      }
    }{
      \xustsetup{system = windows}
    }
  }
\fi

% XITS 字体于 2018-10-03 更改了字体的文件名，所以需要判断。
% 原文件名为 \file{xits-regular.otf}、\file{xits-math.otf} 等，
% 后改为 \file{XITS-Regular.otf}、\file{XITSMath-Regular.otf} 等。
\let\xust@font@family@xits\@empty
\newcommand\xust@set@xits@names{%
  \ifx\xust@font@family@xits\@empty
    \IfFontExistsTF{XITSMath-Regular.otf}{%
      \gdef\xust@font@family@xits{XITS}%
      \gdef\xust@font@style@xits@rm{Regular}%
      \gdef\xust@font@style@xits@bf{Bold}%
      \gdef\xust@font@style@xits@it{Italic}%
      \gdef\xust@font@style@xits@bfit{BoldItalic}%
      \gdef\xust@font@name@xits@math@rm{XITSMath-Regular}%
      \gdef\xust@font@name@xits@math@bf{XITSMath-Bold}%
    }{%
      \gdef\xust@font@family@xits{xits}%
      \gdef\xust@font@style@xits@rm{regular}%
      \gdef\xust@font@style@xits@bf{bold}%
      \gdef\xust@font@style@xits@it{italic}%
      \gdef\xust@font@style@xits@bfit{bolditalic}%
      \gdef\xust@font@name@xits@math@rm{xits-math}%
      \gdef\xust@font@name@xits@math@bf{xits-mathbold}%
    }%
  \fi
}

% Libertinus 字体同样。
\let\xust@font@family@libertinus\@empty
\newcommand\xust@set@libertinus@names{%
  \ifx\xust@font@family@libertinus\@empty
    \IfFontExistsTF{LibertinusSerif-Regular.otf}{%
      \gdef\xust@font@family@libertinus@serif{LibertinusSerif}%
      \gdef\xust@font@family@libertinus@sans{LibertinusSans}%
      \gdef\xust@font@name@libertinus@math{LibertinusMath-Regular}%
      \gdef\xust@font@style@libertinus@rm{Regular}%
      \gdef\xust@font@style@libertinus@bf{Bold}%
      \gdef\xust@font@style@libertinus@it{Italic}%
      \gdef\xust@font@style@libertinus@bfit{BoldItalic}%
    }{%
      \gdef\xust@font@family@libertinus@serif{libertinusserif}%
      \gdef\xust@font@family@libertinus@sans{libertinussans}%
      \gdef\xust@font@name@libertinus@math{libertinusmath-regular}%
      \gdef\xust@font@style@libertinus@rm{regular}%
      \gdef\xust@font@style@libertinus@bf{bold}%
      \gdef\xust@font@style@libertinus@it{italic}%
      \gdef\xust@font@style@libertinus@bfit{bolditalic}%
    }%
  \fi
}

% 《撰写手册》要求西文字体使用 Times New Roman 和 Arial，
% 但是在 Linux 下没有这两个字体，所以使用它们的克隆版 TeX Gyre Termes 和
% TeX Gyre Heros。
\ifxust@font@auto
  \ifxust@system@unix
    \xustsetup{font=xits}
  \else
    \xustsetup{font=times}
  \fi
\fi
\newcommand\xust@load@font@times{%
  \setmainfont{Times New Roman}%
  \setsansfont{Arial}%
  \ifxust@system@mac
    \setmonofont{Menlo}[Scale = MatchLowercase]%
  \else
    \setmonofont{Courier New}[Scale = MatchLowercase]%
  \fi
}
\newcommand\xust@load@font@termes{%
  \setmainfont{texgyretermes}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \xust@load@texgyre@sans@mono
}
\newcommand\xust@load@texgyre@sans@mono{%
  \setsansfont{texgyreheros}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
    Scale          = MatchLowercase,
  ]%
  \setmonofont{texgyrecursor}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
    Scale          = MatchLowercase,
  ]%
}
\newcommand\xust@load@font@xits{%
  \xust@set@xits@names
  \setmainfont{\xust@font@family@xits}[
    Extension      = .otf,
    UprightFont    = *-\xust@font@style@xits@rm,
    BoldFont       = *-\xust@font@style@xits@bf,
    ItalicFont     = *-\xust@font@style@xits@it,
    BoldItalicFont = *-\xust@font@style@xits@bfit,
  ]%
  \xust@load@texgyre@sans@mono
}
\newcommand\xust@load@font@libertinus{%
  \xust@set@libertinus@names
  \setmainfont{\xust@font@family@libertinus@serif}[
    Extension      = .otf,
    UprightFont    = *-\xust@font@style@libertinus@rm,
    BoldFont       = *-\xust@font@style@libertinus@bf,
    ItalicFont     = *-\xust@font@style@libertinus@it,
    BoldItalicFont = *-\xust@font@style@libertinus@bfit,
  ]%
  \setsansfont{\xust@font@family@libertinus@sans}[
    Extension      = .otf,
    UprightFont    = *-\xust@font@style@libertinus@rm,
    BoldFont       = *-\xust@font@style@libertinus@bf,
    ItalicFont     = *-\xust@font@style@libertinus@it,
  ]%
  \setmonofont{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}
\newcommand\xust@load@font@lm{%
  \setmainfont{lmroman10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setsansfont{lmsans10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
  \setmonofont{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}
\newcommand\xust@load@font{%
  \@nameuse{xust@load@font@\xust@font}%
}
\xust@load@font
\xust@option@hook{font}{\xust@load@font}

% 中文字体
\ifxust@cjk@font@auto
  \ifxust@system@mac
    \xustsetup{cjk-font = mac}
  \else
    \ifxust@system@windows
      \xustsetup{cjk-font = windows}
    \else
      \IfFontExistsTF{Noto Serif CJK SC}{
        \xustsetup{cjk-font = noto}
      }{
        \xustsetup{cjk-font = fandol}
      }
    \fi
  \fi
\fi
\newcommand\xust@load@cjk@font@windows{%
  \xeCJKsetup{EmboldenFactor=2}
  \setCJKmainfont{SimSun}[
    AutoFakeBold = true,
    ItalicFont   = KaiTi,
  ]%
  \setCJKsansfont{SimHei}[AutoFakeBold]%
  \setCJKmonofont{FangSong}%
  \setCJKfamilyfont{zhsong}{SimSun}[AutoFakeBold]%
  \setCJKfamilyfont{zhhei}{SimHei}[AutoFakeBold]%
  \setCJKfamilyfont{zhkai}{KaiTi}%
  \setCJKfamilyfont{zhfs}{FangSong}%
}
\newcommand\xust@load@cjk@font@mac{%
  \setCJKmainfont{Songti SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
    ItalicFont     = Kaiti SC,
    BoldItalicFont = Kaiti SC Bold,
  ]%
  \setCJKsansfont{Heiti SC}[BoldFont=* Medium]%
  \setCJKmonofont{STFangsong}
  \setCJKfamilyfont{zhsong}{Songti SC}[
    UprightFont = * Light,
      BoldFont  = * Bold,
  ]%
  \setCJKfamilyfont{zhhei}{Heiti SC}[
    UprightFont = * Light,
    BoldFont    = * Medium,
  ]%
  \setCJKfamilyfont{zhfs}{STFangsong}%
  \setCJKfamilyfont{zhkai}{Kaiti SC}[BoldFont = * Bold]%
  \setCJKfamilyfont{zhli}{Baoli SC}%
  \setCJKfamilyfont{zhyuan}{Yuanyi SC}[
    UprightFont = * Light,
    BoldFont    = * Bold,
  ]%
  \xeCJKsetwidth{‘’“”}{1em}%
}

% 注意 Noto CJK 的 regular 字重名字不带“Regular”。
\newcommand\xust@load@cjk@font@noto{%
  \setCJKmainfont{Noto Serif CJK SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
    ItalicFont     = FandolKai-Regular,
    ItalicFeatures = {Extension = .otf},
  ]%
  \setCJKsansfont{Noto Sans CJK SC}[
    BoldFont    = * Medium,
  ]%
  \setCJKmonofont{Noto Sans Mono CJK SC}%
  \setCJKfamilyfont{zhsong}{Noto Serif CJK SC}[
    UprightFont = * Light,
    UprightFont = * Bold,
  ]%
  \setCJKfamilyfont{zhhei}{Noto Sans CJK SC}[
    BoldFont    = * Medium,
  ]%
  \setCJKfamilyfont{zhfs}{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhkai}{FandolKai}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
}
\newcommand\xust@load@cjk@font@fandol{%
  \setCJKmainfont{FandolSong}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
    ItalicFont  = FandolKai-Regular,
  ]%
  \setCJKsansfont{FandolHei}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKmonofont{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhsong}{FandolSong}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKfamilyfont{zhhei}{FandolHei}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKfamilyfont{zhfs}{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhkai}{FandolKai}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
}
\ifxust@cjk@font@none\else
  \providecommand\songti{\CJKfamily{zhsong}}
  \providecommand\heiti{\CJKfamily{zhhei}}
  \providecommand\fangsong{\CJKfamily{zhfs}}
  \providecommand\kaishu{\CJKfamily{zhkai}}
\fi
\newcommand\xust@load@cjk@font{%
  \@nameuse{xust@load@cjk@font@\xust@cjk@font}%
}
\xust@load@cjk@font
\xust@option@hook{cjk-font}{\xust@load@cjk@font}

% 使用 \pkg{unicode-math} 配置数学字体。
\unimathsetup{
  math-style = ISO,
  bold-style = ISO,
  nabla      = upright,
  partial    = upright,
}
\newcommand\xust@load@math@font@xits{%
  \xust@set@xits@names
  \setmathfont{\xust@font@name@xits@math@rm}[
    Extension    = .otf,
    BoldFont     = \xust@font@name@xits@math@bf,
    StylisticSet = 8,
  ]%
  \setmathfont{\xust@font@name@xits@math@rm}[
    Extension    = .otf,
    StylisticSet = 1,
    range        = {cal,bfcal},
  ]%
}
\newcommand\xust@load@math@font@stix{%
  \setmathfont{STIX2Math}[
    Extension    = .otf,
    StylisticSet = 8,
  ]%
  \setmathfont{STIX2Math}[
    Extension    = .otf,
    StylisticSet = 1,
    range        = {cal,bfcal},
  ]%
}
\newcommand\xust@load@math@font@libertinus{%
  \xust@set@libertinus@names
  \setmathfont{\xust@font@name@libertinus@math .otf}%
}
\newcommand\xust@load@math@font@lm{%
  \setmathfont{latinmodern-math.otf}%
}
\newcommand\xust@load@math@font{%
  \csname xust@load@math@font@\xust@math@font\endcsname
}
\xust@load@math@font
\xust@option@hook{math-font}{\xust@load@math@font}

% 研究生的五级节标题和脚注需要使用带圈数字，
% 但 Times New Roman 没有这些符号的字形，而华文宋体和中易宋体提供了这些字形，
% 配置在 \cs{xust@circlefont}。
\ifxust@font@times
  \ifxust@cjk@font@mac
    \newfontfamily\xust@circlefont{Songti SC Light}
  \else
    \ifxust@cjk@font@windows
      \newfontfamily\xust@circlefont{SimSun}
    \fi
  \fi
\else
  \xust@set@xits@names
  \newfontfamily\xust@circlefont{%
    \xust@font@family@xits-\xust@font@style@xits@rm.otf%
  }
\fi

% 目前最广泛使用的印刷的长度单位点（磅）通常指 PostScript point
% \footnote{\url{https://en.wikipedia.org/wiki/Point_(typography)}}，
% 在 \LaTeX{} 中是 bp，比默认的 pt 略大。
% 这里保存起来可以节约编译时间。
\newdimen\bp@
\bp@=1bp

% 下面设置字号。正文字号12bp，研究生行距20bp，本科生行距22bp；
% 其他命令的行距按照相同的的比例设置，如表~\ref{tab:fontsize}。
% \begin{table}[htb]
%   \centering
%   \caption{标准字体命令与字号、行距的对应}
%   \label{tab:fontsize}
%   \begin{tabular}{lllll}
%     \toprule
%     字体命令          & 字号 & bp   & 研究生行距 & 本科生行距 \\
%     \midrule
%     \cs{tiny}         & 小六 & 6.5  & 10.83      & 11.92      \\
%     \cs{scriptsize}   & 六号 & 7.5  & 12.5       & 13.75      \\
%     \cs{footnotesize} & 小五 & 9    & 15         & 16.5       \\
%     \cs{small}        & 五号 & 10.5 & 17.5       & 19.25      \\
%     \cs{normalsize}   & 小四 & 12   & 20         & 22         \\
%     \cs{large}        & 小三 & 15   & 25         & 27.5       \\
%     \cs{Large}        & 小二 & 18   & 30         & 33         \\
%     \cs{LARGE}        & 二号 & 22   & 36.67      & 40.33      \\
%     \cs{huge}         & 小一 & 24   & 40         & 44         \\
%     \cs{Huge}         & 一号 & 26   & 43.33      & 47.67      \\
%     \bottomrule
%   \end{tabular}
% \end{table}
\ifxust@degree@graduate
  \renewcommand\normalsize{%
    \@setfontsize\normalsize{12\bp@}{20\bp@}%
    \abovedisplayskip 12\bp@ \@plus3\bp@ \@minus7\bp@
    \abovedisplayshortskip \z@ \@plus3\bp@
    \belowdisplayshortskip 6.5\bp@ \@plus3.5\bp@ \@minus3\bp@
    \belowdisplayskip \abovedisplayskip
    \let\@listi\@listI}
  \normalsize
  %
  % 注意第~\ref{sec:list} 节去掉了列表的间距，所以不再修改 \cs{@listi}。
  \renewcommand\small{%
    \@setfontsize\small{10.5\bp@}{17.5\bp@}%
    \abovedisplayskip 10.5\bp@ \@plus3\bp@ \@minus6\bp@
    \abovedisplayshortskip \z@ \@plus3\bp@
    \belowdisplayshortskip 6.5\bp@ \@plus3.5\bp@ \@minus3\bp@
    \belowdisplayskip \abovedisplayskip
  }
  \renewcommand\footnotesize{%
    \@setfontsize\footnotesize{9\bp@}{15\bp@}%
    \abovedisplayskip 9\bp@ \@plus2\bp@ \@minus5\bp@
    \abovedisplayshortskip \z@ \@plus3\bp@
    \belowdisplayshortskip 6\bp@ \@plus3\bp@ \@minus3\bp@
    \belowdisplayskip \abovedisplayskip
  }
  \renewcommand\scriptsize{\@setfontsize\scriptsize{7.5\bp@}{12.5\bp@}}
  \renewcommand\tiny{\@setfontsize\tiny{6.5\bp@}{10.83\bp@}}
  \renewcommand\large{\@setfontsize\large{15\bp@}{25\bp@}}
  \renewcommand\Large{\@setfontsize\Large{18\bp@}{30\bp@}}
  \renewcommand\LARGE{\@setfontsize\LARGE{22\bp@}{36.67\bp@}}
  \renewcommand\huge{\@setfontsize\huge{24\bp@}{40\bp@}}
  \renewcommand\Huge{\@setfontsize\Huge{26\bp@}{43.33\bp@}}
\else
  \renewcommand\normalsize{%
    \@setfontsize\normalsize{12\bp@}{22\bp@}%
    \abovedisplayskip 12\bp@ \@plus3\bp@ \@minus7\bp@
    \abovedisplayshortskip \z@ \@plus3\bp@
    \belowdisplayshortskip 6.5\bp@ \@plus3.5\bp@ \@minus3\bp@
    \belowdisplayskip \abovedisplayskip
    \let\@listi\@listI}
  \normalsize
  \renewcommand\small{%
    \@setfontsize\small{10.5\bp@}{19.25\bp@}%
    \abovedisplayskip 10.5\bp@ \@plus3\bp@ \@minus6\bp@
    \abovedisplayshortskip \z@ \@plus3\bp@
    \belowdisplayshortskip 6.5\bp@ \@plus3.5\bp@ \@minus3\bp@
    \belowdisplayskip \abovedisplayskip
  }
  \renewcommand\footnotesize{%
    \@setfontsize\footnotesize{9\bp@}{16.5\bp@}%
    \abovedisplayskip 9\bp@ \@plus2\bp@ \@minus5\bp@
    \abovedisplayshortskip \z@ \@plus3\bp@
    \belowdisplayshortskip 6\bp@ \@plus3\bp@ \@minus3\bp@
    \belowdisplayskip \abovedisplayskip
  }
  \renewcommand\scriptsize{\@setfontsize\scriptsize{7.5\bp@}{13.75\bp@}}
  \renewcommand\tiny{\@setfontsize\tiny{6.5\bp@}{11.92\bp@}}
  \renewcommand\large{\@setfontsize\large{15\bp@}{27.5\bp@}}
  \renewcommand\Large{\@setfontsize\Large{18\bp@}{33\bp@}}
  \renewcommand\LARGE{\@setfontsize\LARGE{22\bp@}{40.33\bp@}}
  \renewcommand\huge{\@setfontsize\huge{24\bp@}{44\bp@}}
  \renewcommand\Huge{\@setfontsize\Huge{26\bp@}{47.67\bp@}}
\fi

% 设置行距的倍数为 1。
\linespread{1}\selectfont


% \subsection{处理语言}

% 由于 Unicode 的一些标点符号是中西文混用的：
% U+00B7、U+2013、U+2014、U+2018、U+2019、
% U+201C、U+201D、U+2025、U+2026、U+2E3A，
% 所以要根据语言设置正确的字体。
% https://github.com/CTeX-org/ctex-kit/issues/389
\newcommand\xust@set@punctuations{%
  \ifxust@language@chinese
    \xeCJKDeclareCharClass{FullLeft}{"2018, "201C}%
    \xeCJKDeclareCharClass{FullRight}{
      "00B7, "2019, "201D, "2013, "2014, "2025, "2026, "2E3A,
    }%
  \else
    \xeCJKDeclareCharClass{HalfLeft}{"2018, "201C}%
    \xeCJKDeclareCharClass{HalfRight}{
      "00B7, "2019, "201D, "2013, "2014, "2025, "2026, "2E3A,
    }%
  \fi
}
\xust@set@punctuations
\xust@option@hook{language}{\xust@set@punctuations}

% 这里设置了中英文的各种名字。

% 由于《撰写手册》中的“speciality”一词使用的是英式拼法，
% 所以“acknowledgements”也保持一致。
\newcommand\xust@set@chapter@names{%
  \ifxust@main@language@chinese
    \def\contentsname{目录}%
    \def\listfigurename{插图清单}%
    \def\listtablename{表格清单}%
    \def\bibname{参考文献}%
    \def\appendixname{附录}%
    \def\xust@acknowledgements@name{致谢}%
    \def\xust@publication@name{在读期间发表的学术论文与取得的研究成果}%
    \newcommand\xust@notation@name{符号说明}%
  \else
    \def\contentsname{Contents}%
    \def\listfigurename{List of Figures}%
    \def\listtablename{List of Tables}%
    \ctexset{
      chapter/name   = {\chaptername\space},
    }%
    \def\bibname{Bibliography}%
    \def\appendixname{Appendix}%
    \def\xust@acknowledgements@name{Acknowledgements}%
    \def\xust@publication@name{Publications}%
    \def\xust@notation@name{Notation}%
  \fi
}
\xust@set@chapter@names
\xust@option@hook{main-language}{\xust@set@chapter@names}

% 这部分名称在正文中局部地修改语言时会发生变化。
\newcommand\xust@set@names{%
  \ifxust@language@chinese
    \def\figurename{图}%
    \def\tablename{表}%
  \else
    \def\figurename{Figure}%
    \def\tablename{Table}%
  \fi
}
\xust@set@names
\xust@option@hook{language}{\xust@set@names}


% \subsection{纸张和页面}
% 使用 \pkg{geometry} 宏包设置纸张和页面。

% 纸张：A4；

% 页面设置：上 40 mm，下、左 25 mm，右 23 mm，论文专用纸中已印有页眉不再单独设置

\geometry{
  paper  = a4paper,
  left   = 25mm,
  right  = 23mm,
  top    = 40mm,
  bottom = 25mm,
}

% 使用 \pkg{fancy} 需要先调用 |\pagestyle{fancy}| 再修改 \cs{chaptermark} 和
% \cs{sectionmark}。
\pagestyle{fancy}
\let\sectionmark\@gobble
\renewcommand\headrulewidth{0.4\p@}

% 使用 \pkg{ctex} 的 \cs{ctex\_patch\_cmd:Nnn} 命令。
\newcommand\xust@patchcmd{\csname ctex_patch_cmd:Nnn\endcsname}

% 页眉与该部分的章标题相同，宋体 10.5 磅（五号）居中。
% 页码：宋体 10.5 磅、页面下脚居中。
\newcommand\xust@hf@font{\fontsize{10.5\bp@}{12\bp@}\selectfont}
\newcommand\xust@header{\leftmark}
\xust@patchcmd\chaptermark{\MakeUppercase}{}
\xust@patchcmd\chaptermark{#1}{\xust@spacetitle{#1}}

% 重定义默认的 |plain| page style，会显示页眉和页脚。
\fancypagestyle{plain}{%
  \fancyhf{}%
  \renewcommand{\headrulewidth}{0.0pt}  % 页眉线宽度, 默认为 0.4pt
  \renewcommand{\footrulewidth}{0.0pt}  % 页脚线宽度, 默认0pt
  \fancyfoot[C]{\xust@hf@font{-\thepage-}}%
}
\pagestyle{plain}

% |headings| 只有页眉，没有页脚，用于研究生的符号说明和本科生的 front matter。
% \fancypagestyle{headings}{\fancyfoot{}}

% 每章第一页默认会设置特殊的 page style，我们希望它不改变页眉页脚，
% 所以定义一个 |none|。
\def\ps@none{}
\ctexset{chapter/pagestyle=none}

% 空白页不加页眉和页码。
\def\cleardoublepage{\clearpage\if@twoside \ifodd\c@page\else
  \hbox{}\thispagestyle{empty}\newpage\if@twocolumn\hbox{}\newpage\fi\fi\fi}

  % 从“中文摘要”开始页码用大写罗马数字
\renewcommand\frontmatter{%
  \cleardoublepage
  \@mainmatterfalse
  \pagenumbering{Roman}%
  \pagestyle{plain}%
}

% 正文部分另页起
\renewcommand\mainmatter{
  \clearpage
  \pagenumbering{arabic}
  \pagestyle{plain}
  \@mainmattertrue
}
  %
  %
  % \subsection{封面}
  %
  %
  % 定义用户接口：
\xust@define@key{
  title = {
    default = {论文题目},
  },
  title* = {
    default = {Title},
    name    = title@en,
  },
  author = {
    default = {作者姓名},
  },
  author* = {
    default = {Author Name},
    name    = author@en,
  },
  speciality = {
    default = {专业},
  },
  speciality* = {
    default = {Speciality},
    name    = speciality@en,
  },
  supervisor = {
    default = {导师姓名},
  },
  supervisor* = {
    default = {Supervisor Name},
    name    = supervisor@en,
  },
  date = {
    default = {\the\year-\two@digits{\month}-\two@digits{\day}},
  },
  professional-type = {
    name = professional@type,
  },
  professional-type* = {
    name = professional@type@en,
  },
  secret-level = {
    name    = secret@level,
  },
  secret-level* = {
    name    = secret@level@en,
  },
  secret-year = {
    name    = secret@year,
  },
  keywords,
  keywords* = {
    name    = keywords@en,
  },
}

% 导师一栏可能有多个姓名，所以用 \opt{supervisor} 进行收集，
% 然后使用本命令来输出要求的格式，
% 类似于 \LaTeX3 的 \cs{clist\_use:Nn}。
\newcommand\xust@clist@count[1]{%
  \csname clist_count:N\endcsname{#1}%
}
\newcommand\xust@clist@use[2]{%
  \csname clist_use:Nn\endcsname{#1}{#2}%
}
\newcommand\xust@supervisor@names{%
  \xust@clist@use{\xust@supervisor}{\quad}
}
\newcounter{xust@count}
\newcommand\xust@supervisor@en@line{%
  \setcounter{xust@count}{\xust@clist@count{\xust@supervisor@en}}%
  \ifnum\c@xust@count>1\relax
    Supervisors:%
  \else
    Supervisor:%
  \fi
  \space\xust@clist@use{\xust@supervisor@en}{, }%
}

% 输出日期的给定格式：\cs{xust@format@date}\marg{format}\marg{date}，
% 其中格式 \meta{format} 接受三个参数分别对应年、月、日，
% \meta{date} 是 ISO 格式的日期（yyyy-mm-dd）。
\newcommand\xust@format@date[2]{%
  \edef\xust@@date{#2}%
  \def\xust@@process@date##1-##2-##3\@nil{%
    #1{##1}{##2}{##3}%
  }%
  \expandafter\xust@@process@date\xust@@date\@nil
}
\newcommand\xust@date@format@zh[3]{\zhdigits{#1}年\zhnumber{#2}月\zhnumber{#3}日}
\newcommand\xust@date@month[1]{%
  \ifcase\number#1\or
    January\or February\or March\or April\or May\or June\or
    July\or August\or September\or October\or November\or December%
  \fi
}
\newcommand\xust@date@format@en[3]{\xust@date@month{#2} \number#3, #1}
\newcommand\xust@date@zh{\xust@format@date{\xust@date@format@zh}{\xust@date}}
\newcommand\xust@date@en{\xust@format@date{\xust@date@format@en}{\xust@date}}

% 定义一些常量。
\ifxust@degree@doctor
  \newcommand\xust@thesis@name{博士学位论文}
  \newcommand\xust@thesis@name@en{A dissertation for doctor's degree}
\else
  \ifxust@degree@master
    \newcommand\xust@thesis@name{硕士学位论文}
    \newcommand\xust@thesis@name@en{A dissertation for master's degree}
  \else
    \newcommand\xust@thesis@name{学士学位论文}
    \newcommand\xust@thesis@name@en{A dissertation for bachelor's degree}
  \fi
\fi
\ifxust@degree@type@academic
  \newcommand\xust@speciality@name{学科专业}
\else
  \ifxust@degree@doctor
    \renewcommand\xust@thesis@name{专业博士学位论文}
  \else
    \renewcommand\xust@thesis@name{专业硕士学位论文}
  \fi
  \ifxust@cjk@font@mac
    \providecommand\lishu{\CJKfamily{zhli}}
  \else
    \ifxust@cjk@font@windows
      \setCJKfamilyfont{zhli}{LiSu}
      \providecommand\lishu{\CJKfamily{zhli}}
    \else
      \xust@warning{LiShu font is required}
      \providecommand\lishu{\sffamily}
    \fi
  \fi
  \newcommand\xust@speciality@name{专业领域}
\fi

% 定义校徽颜色，来源 XUST VI
\definecolor{xustgreen}{cmyk}{0.84,0.00,0.37,0.62}    % XUST 深绿色
\definecolor{xustlgreen}{cmyk}{0.32,0.00,0.63,0.37} % XUST 浅绿色
\definecolor{xustblue}{cmyk}{0.73,0.39,0,0.29}   % XUST 靛蓝
\definecolor{xustred}{cmyk}{0.00,0.86,0.82,0.10}     % XUST 标准红

% 添加 PDF 书签，在 \pkg{hyperref} 载入后才有效。
\newcommand\xust@pdfbookmark{\@gobble}
% 重定义 \env{titlepage} 环境，不修改页码。
\renewenvironment{titlepage}{%
  \cleardoublepage
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse\newpage
  \fi
  \thispagestyle{empty}%
}{%
  \if@restonecol\twocolumn \else \newpage \fi
}

\newcommand{\xust@includebadge}[1]{
  \ifxust@badge@color@green
    \includegraphics[height={#1}cm]{xust/badge-green}
  \else
    \ifxust@badge@color@black
      \includegraphics[height={#1}cm]{xust/badge-black}
    \else
      \ifxust@badge@color@blue
        \includegraphics[height={#1}cm]{xust/badge-blue}
      \else
        \includegraphics[height={#1}cm]{xust/badge-red}
      \fi
    \fi
  \fi
}

% 中文封面：
% 密级仿宋 14 磅；
% 论文类型黑体 56 磅；
% 论文题目黑体 26 磅加粗居中，单倍行距；
% 作者姓名宋体 16 磅，单倍行距；
% 注意这里的“单倍行距”的地方开启了“对齐到网格”，所以实际行距有所偏差，
% 所以只能使用直尺测量。
\newcommand\xust@makezhtitle{%
  \xustsetup{language=chinese}
  \begin{titlepage}%
    \xust@pdfbookmark{封面}%
    \centering
    \parbox[t][0.6cm][t]{\textwidth}{%
      \raggedleft\fangsong\fontsize{14\bp@}{14\bp@}\selectfont
      \null\xust@secret@level\par}\par
    \vskip 0.5cm%
    \includegraphics[height=1.3cm]{xust/name}\par
    \vskip 0.6cm%
    {\sffamily\fontsize{56\bp@}{56\bp@}\selectfont
      \xust@thesis@name\par}%
    \ifxust@degree@type@academic
      \vskip 2.0cm%
    \else
      \vskip 0.8cm%
      {\lishu\fontsize{26\bp@}{26\bp@}\selectfont
        （\xust@professional@type）\par}%
      \vskip 1.0cm%
    \fi
    \xust@includebadge{4.1}\par
    \vskip 0.9cm%
    \parbox[t][3.5cm][c]{\textwidth}{%
      \centering\sffamily\bfseries\fontsize{26\bp@}{50\bp@}\selectfont
      \xust@title\par}\par
    \vskip 0.6cm%
    {\fontsize{16\bp@}{31\bp@}\selectfont
      \begin{tabular}{@{}l@{\hspace{\ccwd}}l@{}}%
        \textsf{作者姓名：} & \xust@author \\
        \textsf{\xust@speciality@name：} & \xust@speciality \\
        \textsf{导师姓名：} & \xust@supervisor@names \\
        \textsf{完成时间：} & \xust@date@zh
      \end{tabular}\par}%
  \end{titlepage}%
  \xust@reset@main@language
}

% 英文封面
\newcommand\xust@makeentitle{%
  \xustsetup{language=english}
  \begin{titlepage}%
    \xust@pdfbookmark{Title page}%
    \centering
    \parbox[t][0.4cm][t]{\textwidth}{%
      \raggedleft\fontsize{14\bp@}{14\bp@}\selectfont
      \null\xust@secret@level@en\par}\par
    \vskip 0.5cm%
    {\sffamily\fontsize{20\bp@}{30\bp@}\selectfont
      Xi'an University of Science and Technology\par}%
    {\sffamily\fontsize{26\bp@}{30\bp@}\selectfont
      \xust@thesis@name@en\par}%
    \ifxust@degree@type@academic\else
      {\fontsize{16\bp@}{32\bp@}\selectfont
        (\xust@professional@type@en)\par}%
    \fi
    \vskip 2.5cm%
    \xust@includebadge{4.5}\par
    \vskip 0.5cm%
    \parbox[t][4.5cm][c]{\textwidth}{%
      \centering\sffamily\bfseries\fontsize{26\bp@}{30\bp@}\selectfont
      \xust@title@en\par}\par
    \vskip 1.6cm%
    {\fontsize{16\bp@}{30\bp@}\selectfont
      \begin{tabular}{@{}l@{}}%
        Author:        \xust@author@en \\
        Speciality:    \xust@speciality@en \\
        \xust@supervisor@en@line \\
        Finished time: \xust@date@en
      \end{tabular}\par}%
  \end{titlepage}%
  \xust@reset@main@language
}

% 重新定义 \cs{maketitle}，调用 \cs{xust@makezhtitle}, \cs{xust@makeentitle}
% 分别生成中、英文封面。
\renewcommand\maketitle{%
  \newgeometry{margin=2.54cm}%
  \pagenumbering{Alph}%
  \pagestyle{empty}%
  \ifxust@degree@bachelor
  \xust@makezhtitle
  \else
  \xust@makezhtitle
  \xust@makeentitle
  \fi
  \restoregeometry
  \pagestyle{plain}%
}


% \subsection{原创性声明}

% 定义原创性声明
\newcommand\xust@originality{%
  本人声明所呈交的学位论文，是本人在导师指导下进行研究工作所取得的成果。%
  除已特别加以标注和致谢的地方外，论文中不包含任何他人已经发表或撰写过的%
  研究成果。%
  与我一同工作的同志对本研究所做的贡献均已在论文中作了明确的说明。}
\newcommand\xust@authorization{%
  作为申请学位的条件之一，学位论文著作权拥有者授权西安科技大学拥有%
  学位论文的部分使用权，%
  即：学校有权按有关规定向国家有关部门或机构送交论文的复印件和电子版，%
  允许论文被查阅和借阅，可以将学位论文编入《中国学位论文全文数据库》等%
  有关数据库进行检索，可以采用影印、缩印或扫描等复制手段保存、汇编学位论文。%
  本人提交的电子文档的内容和纸质论文的内容相一致。\par
  保密的学位论文在解密后也遵守此规定。}
  %
  % 生成空的下划线
\newcommand\xust@underline[2][3.2cm]{\underline{\hb@xt@ #1{\hss#2\hss}}}

\newcommand\xust@checkbox{%
  \makebox[\z@][l]{$\square$}%
  \raisebox{-0.2ex}{\hspace{0.1em}$\checkmark$}%
}

\newcommand\copyrightpage{%
  \begin{titlepage}%
    \xust@pdfbookmark{原创性和授权使用声明}%
    \null
    \vskip 0.3cm%
    {\centering\sffamily\fontsize{16\bp@}{32\bp@}\selectfont
      西安科技大学学位论文原创性声明\par}%
    \vskip 0.7cm%
    \xust@originality\par
    \vskip 1.3cm%
    作者签名：\xust@underline{}\hspace{2.7cm}%
    签字日期：\xust@underline{}\par
    \vskip 1.9cm%
    {\centering\sffamily\fontsize{16\bp@}{32\bp@}\selectfont
      西安科技大学学位论文授权使用声明\par}%
    \vskip 0.7cm%
    \xust@authorization\par
    \vskip 0.6cm%
    \ifx\xust@secret@level\@empty
      \xust@checkbox{} 公开\quad
      $\square$ 保密（\xust@underline[0.85cm]{}年）\par
    \else
      $\square$ 公开\quad
      \xust@checkbox{} 保密（\xust@underline[0.8cm]{\xust@secret@year}年）\par
    \fi
    \vskip 0.5cm%
    作者签名：\xust@underline{}\hspace{2.7cm}%
    导师签名：\xust@underline{}\par
    \vskip 0.5cm%
    签字日期：\xust@underline{}\hspace{2.7cm}%
    签字日期：\xust@underline{}\par
  \end{titlepage}%
}
\ifxust@degree@bachelor
  \let\copyrightpage\relax
\fi
% Reserved for compatibility until 2020-07-01.
\let\makestatement\copyrightpage


% \subsection{章节标题}

% 标题最多允许使用五级。
\setcounter{secnumdepth}{5}

% 研究生规定章题为两字时中间空两个空格，三字及以上不空。
% 这里用 \LaTeX3 的 \cs{str\_count:N} 判断字数。
% 注意，\pkg{stringstrings} 宏包会导致范数命令 \verb+\|+ 被修改。
\newcount\xust@titlelength
\DeclareRobustCommand\xust@spacetitle[1]{%
  \xust@titlelength=\csname str_count:N\endcsname{#1}%
  \begingroup
    \ifcase\xust@titlelength
      \or\or
        \ziju{1}
    \fi
    #1%
  \endgroup
}

% 五级节标题和脚注需要使用带圈的数字，这里使用 \cs{xust@circlefont} ：
\newcommand\xust@textcircled[1]{%
  \ifnum\value{#1}<21\relax
    {\xust@circlefont\symbol{\numexpr\value{#1} + "245F\relax}}%
  \else
    \xust@error{Cannot display more than 10 footnotes}%
  \fi
}

% 用 \pkg{ctex} 的接口设置全部章节标题格式。

% 各章标题 (一级标题)：黑体小三加粗居中，1.5 倍行距，段前 0.5 ，段后 0.5 ，
% 章序号与章名间空一格。

% 由于 Word 模板中使用“单倍行距”，还“对齐到网格”，这在 TeX 中不容易实现。
% 所以目前按照默认的行距。

% 注意 \pkg{ctex} v2.4.3 以下版本的bug会导致章节标题前后的距离的实际值偏大。
% 另外 \pkg{ctex} v2.2 前的beforeskip的符号有特殊意义。
\ctexset{
  chapter = {
    format      = \centering\sffamily\bfseries\fontsize{15\bp@}{37.5\bp@}\selectfont,
    name        = {,},
    titleformat = \xust@spacetitle,
    number      = \thechapter,
    aftername   = \enskip,
    beforeskip  = 12.5\bp@,
    afterskip   = 12.5\bp@,
  },
}

% 二级节标题：宋体四号加粗居中，1.5 倍行距，段前 1.0，段后 0.5，
% 序号与题名间空一格。
\ctexset{
  section = {
    format     = \centering\rmfamily\bfseries\fontsize{14\bp@}{35\bp@}\selectfont,
    aftername  = \enskip,
    beforeskip = 23.33\bp@,
    afterskip  = 11.67\bp@,
  },
  %
  % 三级节标题：宋体小四加粗左对齐，20 磅行距，段前 0.5，段后 0.5，
  % 序号与题名间空一格。
  subsection = {
    format     = \rmfamily\bfseries\fontsize{12\bp@}{20\bp@}\selectfont,
    aftername  = \enskip,
    beforeskip = 10\bp@,
    afterskip  = 10\bp@,
  },
  %
  % 四级节标题：宋体小四，左缩进两字，行距 20 磅，段前段后 0 磅，序号与题名间空一格。
  subsubsection = {
    format     = \rmfamily\fontsize{12\bp@}{20\bp@}\selectfont,
    number     = \arabic{chapter}.\arabic{section}.\arabic{subsection}.\arabic{subsubsection},
    aftername  = \enskip,
    indent     = 2\ccwd,
    beforeskip = \z@,
    afterskip  = \z@,
  },
  %
  % 五级节标题：宋体小四，左缩进两字，行距 20 磅，段前段后 0 磅，序号与题名间空一格。
  paragraph = {
    format     = \rmfamily\fontsize{12\bp@}{20\bp@}\selectfont,
    number     = \arabic{paragraph}),
    aftername  = \enskip,
    indent     = 2\ccwd,
    beforeskip = \z@,
    afterskip  = \z@,
    runin      = false,
  },
  %
  % 六级节标题：宋体小四，左缩进两字，行距 20 磅，段前段后 0 磅，序号与题名间空一格。
  subparagraph = {
    format     = \rmfamily\fontsize{12\bp@}{20\bp@}\selectfont,
    number     = (\arabic{subparagraph}),
    aftername  = \enskip,
    indent     = 2\ccwd,
    beforeskip = \z@,
    afterskip  = \z@,
    runin      = false,
  },
}

% 默认的 \cs{chapter*} 生成的章标题没有编号、不更改页眉，
% 也不添加进目录或 PDF 书签。
% 然而像摘要、目录、符号说明这样的章节，它们不需要编号、不加入目录，
% 但是需要修改页眉，并且加入 PDF 标签。
% 所以我们新定义 \cs{xust@chapter} 用于处理这些章节。%
\NewDocumentCommand\xust@chapter{o m}{%
  \if@openright\cleardoublepage\else\clearpage\fi
  \IfValueTF{#1}{%
    \xust@pdfbookmark{#1}%
    \chaptermark{#1}%
  }{%
    \xust@pdfbookmark{#2}%
    \chaptermark{#2}%
  }%
  \chapter*{#2}}
  %
  %
  % \subsection{摘要}
  %
  % 中文摘要环境。
  % 判断 \cs{xust@tocloaded} 是为了防止本科生未调整摘要位置时的目录页码缺失。
\newcommand\xust@keywords@text{%
  \xust@clist@use{\xust@keywords}{；}%
}
\newcommand\xust@keywords@en@text{%
  \xust@clist@use{\xust@keywords@en}{; }%
}
\newenvironment{abstract}{%
  \xustsetup{language=chinese}
  \xust@chapter{摘要}%
}{
  \par\null\par\noindent\hangindent=4\ccwd\relax
  \textbf{关键词}：\xust@keywords@text\par
  \xust@reset@main@language
}

% 英文摘要环境
\newenvironment{enabstract}{%
  \xustsetup{language=english}
  \xust@chapter[Abstract]{ABSTRACT}%
}{
  \par\null\par\noindent\hangindent=5.3em\relax
  \textbf{Key Words}: \xust@keywords@en@text\par
  \ifxust@degree@graduate
    \cleardoublepage
  \fi
  \xust@reset@main@language
}


% \subsection{目录}

% 判断是否已经加载目录，用于提醒本科生更改摘要和致谢的顺序。
\newif\ifxust@tocloaded

% 研究生规定目录另面起；
\renewcommand\tableofcontents{%
  \xust@chapter{\contentsname}%
  \@starttoc{toc}%
}

% 下面用 \pkg{titletoc} 宏包设置目录内容的格式。
% 先定义目录线：
\newcommand\xust@leaders{\titlerule*[4\bp@]{.}}

% 各章目录要求宋体 12 磅加粗，1.5 倍行距，段前 6 磅，段后 0 磅，两端对齐，
% 页码右对齐，章序号与章名间空一格。

% 另外 \pkg{ctex} 在章目录的序号后加 |\hspace{.3em}|，所以用 \cs{unskip} 修正。
\titlecontents{chapter}
  [\z@]{\addvspace{6\bp@}\rmfamily\fontsize{12\bp@}{30\bp@}\selectfont\bf}
  {\contentspush{\thecontentslabel\enskip}}{}
  {\rm\fontsize{12\bp@}{20\bp@}\selectfont\xust@leaders\contentspage}
%
% 一级节标题目录要求宋体 12 磅，1.5 倍行距，左缩进一字，段前 6 磅，段后 0 磅，
% 两端对齐，页码右对齐，序号与题名间空一字。
% Word 模板中实际是行距 20 磅，段前 0 磅。
\titlecontents{section}
  [\ccwd]{\rmfamily\fontsize{12\bp@}{30\bp@}\selectfont}
  {\contentspush{\thecontentslabel\enskip}}{}
  {\fontsize{12\bp@}{20\bp@}\selectfont\xust@leaders\contentspage}
%
% 二级节标题目录要求宋体 12 磅，1.5 倍行距，左缩进两字，段前 6 磅，段后 0 磅，
% 两端对齐，页码右对齐，序号与题名间空一字。
\titlecontents{subsection}
  [2\ccwd]{\rmfamily\fontsize{12\bp@}{30\bp@}\selectfont}
  {\contentspush{\thecontentslabel\enskip}}{}
  {\fontsize{12\bp@}{20\bp@}\selectfont\xust@leaders\contentspage}

% 本科生要求目录中正文每章前多空一行，而目录、附录等章则不需要空行，
% 所以不能简单判断 \cs{if@mainmatter}，需要重新定义 \cs{mainmatter} 等命令。
% \newif\ifxust@addtocspace
% \ifxust@degree@bachelor
%   \xust@addtocspacetrue
%   \g@addto@macro\frontmatter{\xust@addtocspacefalse}%
%   \g@addto@macro\mainmatter{\xust@addtocspacetrue}%
%   \g@addto@macro\backmatter{\xust@addtocspacefalse}%
%   \g@addto@macro\appendix{\xust@addtocspacefalse}%
% \fi

% % 处理本科生在目录中添加空行。
% \renewcommand\chapter{%
%   \if@openright\cleardoublepage\else\clearpage\fi
%   \thispagestyle{\CTEX@chapter@pagestyle}%
%   \global\@topnum\z@
%   \@afterindenttrue
%   \ifxust@degree@bachelor
%     \ifxust@addtocspace
%       \addtocontents{toc}{\protect\addvspace{12\bp@}}%
%     \fi
%   \fi
%   \secdef\@chapter\@schapter
% }

% 研究生要求图、表的清单须另页起。
\renewcommand\listoffigures{%
  \ifxust@degree@graduate
    \cleardoublepage
  \fi
  \xust@chapter{\listfigurename}%
  \@starttoc{lof}%
}
\titlecontents{figure}
  [2.3em]{\normalsize}
  {\contentslabel{2.3em}}{}
  {\xust@leaders\contentspage}
  %
\renewcommand\listoftables{%
  \ifxust@degree@graduate
    \cleardoublepage
  \fi
  \xust@chapter{\listtablename}%
  \@starttoc{lot}%
}
\titlecontents{table}
  [2.3em]{\normalsize}
  {\contentslabel{2.3em}}{}
  {\xust@leaders\contentspage}
  %
  %
  % \subsection{符号说明}
  %
  % 符号说明另页起，标题字体字号等同论文正文
\newenvironment{notation}{%
  \cleardoublepage
  \xust@chapter{\xust@notation@name}%
}{%
  \clearpage
}%
\newcommand*\notationlabel[1]{#1\hfil}%
\newenvironment{notationlist}[1]{%
  \list{}{%
    \itemsep 3pt%
    \labelwidth #1\relax%
    \labelsep 1em%
    \leftmargin\labelwidth
    \advance\leftmargin\labelsep
    \advance\leftmargin 3em%
    \rightmargin 3em%
    \let\makelabel\notationlabel
  }%
}{%
  \endlist
}


% \subsection{正文}

% \cs{sloppy} 可以减少“overfull boxes”。
\sloppy

% 禁止扩大段间距。（\href{https://github.com/ustctug/ustcthesis/issues/209}{
%   ustctug/ustcthesis\#209}）
\raggedbottom

% 段间距 0 磅。
\setlength{\parskip}{\z@}

% 在 \opt{scheme=plain} 时也首段缩进。
\let\@afterindentfalse\@afterindenttrue
\@afterindenttrue

% URL 的字体设为保持原样。
\urlstyle{same}

% 使用 \pkg{xurl} 宏包的方法，增加 URL 可断行的位置。
\def\UrlBreaks{%
  \do\/%
  \do\a\do\b\do\c\do\d\do\e\do\f\do\g\do\h\do\i\do\j\do\k\do\l%
     \do\m\do\n\do\o\do\p\do\q\do\r\do\s\do\t\do\u\do\v\do\w\do\x\do\y\do\z%
  \do\A\do\B\do\C\do\D\do\E\do\F\do\G\do\H\do\I\do\J\do\K\do\L%
     \do\M\do\N\do\O\do\P\do\Q\do\R\do\S\do\T\do\U\do\V\do\W\do\X\do\Y\do\Z%
  \do0\do1\do2\do3\do4\do5\do6\do7\do8\do9\do=\do/\do.\do:%
  \do\*\do\-\do\~\do\'\do\"\do\-}
\Urlmuskip=0mu plus 0.1mu

% 脚注用带圈的数字：
\renewcommand\thefootnote{\xust@textcircled{footnote}}

% LaTeX 默认脚注按章计数，即每章的开始才重置脚注计数器；我们修改为按页计数。
% 简单的|\@addtoreset{footnote}{page}|并不可靠，
% \footnote{\url{https://texfaq.org/FAQ-footnpp.html}}
% 所以我们使用 \pkg{footmisc} 宏包。

% 脚注线长为版心宽度的四分之一：
\renewcommand\footnoterule{%
  \kern-3\p@
  \hrule\@width.25\textwidth
  \kern2.6\p@}
  %
  % 注文缩进两字：
\renewcommand\@makefntext[1]{%
  \parindent 2\ccwd\relax
  \noindent
  \hb@xt@2\ccwd{\hss\@makefnmark}#1}


% \subsection{列表}
% \label{sec:list}

% 调整列表中各项之间过大的间距。
\setlength\partopsep{\z@}
\newcommand\xust@nolistsep{%
  \parsep 0\p@ \@plus.2\p@
  \topsep 0\p@ \@plus.2\p@
  \itemsep0\p@ \@plus.2\p@
}
\def\@listi{\leftmargin\leftmargini
            \xust@nolistsep}
\let\@listI\@listi
\@listi
\def\@listii {\leftmargin\leftmarginii
              \labelwidth\leftmarginii
              \advance\labelwidth-\labelsep
              \xust@nolistsep}
\def\@listiii{\leftmargin\leftmarginiii
              \labelwidth\leftmarginiii
              \advance\labelwidth-\labelsep
              \xust@nolistsep}


% \subsection{浮动体}

% \LaTeX{} 对放置浮动体的要求比较强，这里按照 UK TeX FAQ 的建议
% \footnote{\url{https://texfaq.org/FAQ-floats}} 对其适当放宽。
\renewcommand\topfraction{.85}
\renewcommand\bottomfraction{.7}
\renewcommand\textfraction{.15}
\renewcommand\floatpagefraction{.66}
\renewcommand\dbltopfraction{.66}
\renewcommand\dblfloatpagefraction{.66}
\setcounter{topnumber}{9}
\setcounter{bottomnumber}{9}
\setcounter{totalnumber}{20}
\setcounter{dbltopnumber}{9}

% 修改默认的浮动体描述符为 |htb|。
\def\fps@figure{htb}
\def\fps@table{htb}

% 修改浮动体序号格式
\renewcommand{\thetable}{\arabic{chapter}-\arabic{table}} % 表
\renewcommand{\thefigure}{\arabic{chapter}-\arabic{figure}} % 图

% 用 \pkg{caption} 宏包设置图、表的格式：

% 图号、图题置于图的下方，宋体 10.5 磅居中加粗，单倍行距，段前 6 磅，段后 12 磅，
% 图号与图题文字之间空一字，图号、图题加粗。
% 图注位于图的下方，左缩进两字，续行悬挂缩进左对齐，两端对齐。

% 表号、表题置于表的上方，宋体 10.5 磅居中加粗，单倍行距，段前 0.5，段后 0.5，
% 表号与表题文字之间空一字，表号、表题加粗。
% 表注左缩进两字，续行悬挂缩进左对齐，两端对齐。
\setlength{\floatsep}{6\bp@}
\setlength{\textfloatsep}{6\bp@}
\setlength{\intextsep}{6\bp@}
\DeclareCaptionLabelSeparator{zhspace}{\hspace{\ccwd}}
\captionsetup{
  format         = hang,
  font           = small,
  labelsep       = zhspace,
  skip           = 6\bp@,
  figureposition = bottom,
  tableposition  = top,
}
\captionsetup{font+=bf}
\captionsetup[figure]{
  belowskip = 6\bp@,
}

% 新定义了 \cs{note} 来生成图表的附注。
% 如果用 \cs{caption} 生成图表的附注会导致图表的序号有误；
% 如果用 \cs{bicaption} 会导致表注无法置于表后，而且对齐方式不对。
\newcommand\note[1]{%
  \begingroup
  \captionsetup{
    format        = plain,
    font          = small,
    justification = justified,
    margin        = 2\ccwd,
    position      = bottom,
  }%
  \caption*{#1}%
  \endgroup
}


% \subsection{数学符号}

% 根据中文的数学排印习惯进行设置：

% 省略号一律居中，所以 \cs{ldots} 不再居于底部。
\ifxust@language@chinese
  \def\mathellipsis{\cdots}
\fi

% 小于等于号、大于等于号要使用倾斜的字形。
\protected\def\le{\leqslant}
\protected\def\ge{\geqslant}
\AtBeginDocument{%
  \renewcommand\leq{\leqslant}%
  \renewcommand\geq{\geqslant}%
}

% 积分号的上下限默认置于上下两侧。
\removenolimits{%
  \int\iint\iiint\iiiint\oint\oiint\oiiint
  \intclockwise\varointclockwise\ointctrclockwise\sumint
  \intbar\intBar\fint\cirfnint\awint\rppolint
  \scpolint\npolint\pointint\sqint\intlarhk\intx
  \intcap\intcup\upint\lowint
}

% 实部、虚部操作符使用罗马体 $\mathrm{Re}$、$\mathrm{Im}$ 而不是 fraktur 体
% $\Re$、$\Im$。
\AtBeginDocument{%
  \renewcommand\Re{\operatorname{Re}}%
  \renewcommand\Im{\operatorname{Im}}%
}

% \cs{nabla} 使用粗正体。
\AtBeginDocument{%
  \renewcommand\nabla{\mbfnabla}%
}

% 兼容旧的粗体命令：\pkg{bm} 的 \cs{bm} 和 \pkg{amsmath} 的 \cs{boldsymbol}。
\DeclareRobustCommand\bm[1]{{\symbf{#1}}}
\DeclareRobustCommand\boldsymbol[1]{{\symbf{#1}}}

% 兼容 \pkg{amssymb} 中的命令。
\newcommand\square{\mdlgwhtsquare}

% 提供一些方便的命令：
\newcommand\upe{\symup{e}}
\newcommand\upi{\symup{i}}
\newcommand\dif{\mathop{}\!\mathrm{d}}


% \subsection{参考文献}

\AtEndOfPackageFile*{biblatex}{
  \AtBeginDocument{
    \ifthenelse{\equal{\blx@bbxfile}{apa}}{\def\bibname{REFERENCES}}{}
    \ifthenelse{\equal{\blx@bbxfile}{apa6}}{\def\bibname{REFERENCES}}{}
    \ifthenelse{\equal{\blx@bbxfile}{mla}}{\def\bibname{WORKS CITED}}{}
    \ifthenelse{\equal{\blx@bbxfile}{mla-new}}{\def\bibname{WORKS CITED}}{}
  }
  \DeclareRobustCommand\inlinecite{\parencite}
  \defbibheading{bibliography}[\bibname]{\@mainmatterfalse\chapter*{\bibname}\addcontentsline{toc}{chapter}{\bibname}}
  % 参考文献列表格式：宋体 10.5 磅，行距 20 磅，续行缩进两字，左对齐。
  % 本科生依然是小四宋体。
  \renewcommand\bibfont{%
    \ifxust@degree@graduate
      \fontsize{10.5bp}{20bp}\selectfont
    \else
      \normalsize
    \fi
  }
  \setlength{\bibitemsep}{0\p@ \@plus.2\p@}
  \setlength{\bibhang}{2\ccwd}
}

% BibTeX 生成参考文献表的样式在 \file{bst} 文件中提供。


% \subsection{附录}

% 定义了一个满足要求的致谢环境：
\newenvironment{acknowledgements}{%
  \chapter*{\xust@acknowledgements@name}%
  \addcontentsline{toc}{chapter}{\xust@acknowledgements@name}
}{}

% 发表成果环境：
\newenvironment{publications}{\chapter{\xust@publication@name}}{}


% \subsection{其他宏包的设置}

% 这些宏包并非格式要求，但是为了方便同学们使用，在这里进行简单设置。


% \subsubsection{\pkg{hyperref} 宏包}

\AtEndOfPackageFile*{hyperref}{
  \hypersetup{
    bookmarksnumbered  = true,
    bookmarksopen      = true,
    bookmarksopenlevel = 1,
    linktoc            = all,
    unicode            = true,
    psdextra           = true,
  }
  %
  % 如果为 \opt{pdf} 样式，设置 hyperlink 颜色
  \ifxust@output@electronic
    \hypersetup{
      colorlinks = true,
      allcolors  = blue,
    }
  \else
    \hypersetup{hidelinks}
  \fi
  %
  % 填写 PDF 元信息。
  \AtBeginDocument{%
    \ifxust@language@chinese
      \hypersetup{
        pdftitle  = \xust@title,
        pdfauthor = \xust@author,
      }%
    \else
      \hypersetup{
        pdftitle  = \xust@title@en,
        pdfauthor = \xust@author@en,
      }%
    \fi
  }
  %
  % 添加 PDF 书签
  %
  \newcounter{xust@bookmarknumber}
  \renewcommand\xust@pdfbookmark[1]{%
    \phantomsection
    \stepcounter{xust@bookmarknumber}%
    \pdfbookmark[0]{#1}{xustchapter.\thexust@bookmarknumber}%
  }
  %
  % 在 PDF 字符串中去掉换行，以减少 \pkg{hyperref} 的警告信息。
  \pdfstringdefDisableCommands{
    \let\\\@empty
    \let\hspace\@gobble
  }
  %
  % \pkg{hyperref} 与 \pkg{unicode-math} 存在一些兼容性问题，见
  % \href{https://github.com/xusttug/xustthesis/issues/223}{%
  %   xusttug/xustthesis\#223}，
  % \href{https://github.com/ho-tex/hyperref/pull/90}{ho-tex/hyperref\#90} 和
  % \href{https://github.com/xusttug/xustthesis/issues/235}{%
  %   xusttug/xustthesis/\#235}。
  \@ifpackagelater{hyperref}{2019/04/27}{}{%
    \g@addto@macro\psdmapshortnames{\let\mu\textmu}%
  }
  %
  % 设置中文的 \cs{autoref}。
  % \footnote{\url{https://tex.stackexchange.com/a/66150/82731}}
  \ifxust@language@chinese
    \def\equationautorefname~#1\null{公式~(#1)\null}
    \def\footnoteautorefname{脚注}
    \def\itemautorefname~#1\null{第~#1~项\null}
    \def\figureautorefname{图}
    \def\tableautorefname{表}
    \def\partautorefname~#1\null{第~#1~部分\null}
    \def\appendixautorefname{附录}
    \def\chapterautorefname~#1\null{第~#1~章\null}
    \def\sectionautorefname~#1\null{第~#1~节\null}
    \def\subsectionautorefname~#1\null{第~#1~小节\null}
    \def\subsubsectionautorefname~#1\null{第~#1~小小节\null}
    \def\paragraphautorefname~#1\null{第~#1~段\null}
    \def\subparagraphautorefname~#1\null{第~#1~小段\null}
    \def\theoremautorefname{定理}
    % \def\thealgorithmautorefname{算法}
    \def\HyRef@autopageref#1{\hyperref[{#1}]{第~\pageref*{#1} 页}}
  \fi
}


% \subsubsection{\pkg{amsthm} 宏包}

\AtEndOfPackageFile*{amsthm}{
  \newtheoremstyle{xustplain}
    {}{}
    {}{2\ccwd}
    {\bfseries}{}
    {\ccwd}{}
  \theoremstyle{xustplain}
  % 定义新的定理
  \ifxust@language@chinese
    \newcommand\xust@assertion@name{断言}
    \newcommand\xust@assumption@name{假设}
    \newcommand\xust@axiom@name{公理}
    \newcommand\xust@corollary@name{推论}
    \newcommand\xust@definition@name{定义}
    \newcommand\xust@example@name{例}
    \newcommand\xust@lemma@name{引理}
    \newcommand\xust@proof@name{证明}
    \newcommand\xust@proposition@name{命题}
    \newcommand\xust@remark@name{注}
    \newcommand\xust@theorem@name{定理}
  \else
    \newcommand\xust@assertion@name{Assertion}
    \newcommand\xust@assumption@name{Assumption}
    \newcommand\xust@axiom@name{Axiom}
    \newcommand\xust@corollary@name{Corollary}
    \newcommand\xust@definition@name{Definition}
    \newcommand\xust@example@name{Example}
    \newcommand\xust@lemma@name{Lemma}
    \newcommand\xust@proof@name{Proof}
    \newcommand\xust@proposition@name{Proposition}
    \newcommand\xust@remark@name{Remark}
    \newcommand\xust@theorem@name{Theorem}
  \fi
  \newtheorem{theorem}             {\xust@theorem@name}    [chapter] % 定理
  \newtheorem{assertion}  [theorem]{\xust@assertion@name}
  \newtheorem{axiom}      [theorem]{\xust@axiom@name}
  \newtheorem{corollary}  [theorem]{\xust@corollary@name}
  \newtheorem{lemma}      [theorem]{\xust@lemma@name}
  \newtheorem{proposition}[theorem]{\xust@proposition@name}
  \newtheorem{assumption}          {\xust@assumption@name} [chapter] % 假设
  \newtheorem{definition}          {\xust@definition@name} [chapter] % 定义
  \newtheorem{example}             {\xust@example@name}    [chapter] % 示例
  \newtheorem*{remark}             {\xust@remark@name}
  \renewcommand{\thetheorem}{\arabic{chapter}-\arabic{theorem}}
  \renewcommand{\theassumption}{\arabic{chapter}-\arabic{assumption}}
  \renewcommand{\thedefinition}{\arabic{chapter}-\arabic{definition}}
  \renewcommand{\theexample}{\arabic{chapter}-\arabic{example}}

  % \pkg{amsthm} 单独定义了 proof 环境，这里重新定义以满足格式要求。
  % 原本模仿 \pkg{amsthm} 写成 |\item[\hskip\labelsep\hskip2\ccwd #1\hskip\ccwd]|，
  % 但是却会多出一些间隙。
  \renewenvironment{proof}[1][\xust@proof@name]{\par
    \pushQED{\qed}%
    \normalfont \topsep6\p@\@plus6\p@\relax
    \trivlist
      \item\relax\hskip2\ccwd
      \textbf{#1}
      \hskip\ccwd\ignorespaces
    }{%
    \popQED\endtrivlist\@endpefalse
  }
}


% \subsubsection{\pkg{algorithm2e} 宏包}

% 按章节编号。
\PassOptionsToPackage{algochapter}{algorithm2e}

\AtEndOfPackageFile*{algorithm2e}{
  \ifxust@language@chinese
    \SetAlgorithmName{算法}{算法}{算法清单}
  \else
    \SetAlgorithmName{Algorithm}{Algorithm}{List of Algorithms}
  \fi
  %
  % 设置算法环境的格式。
  \SetAlCapSkip{6\bp@}
  \SetAlCapFnt{\small}
  \SetAlCapNameFnt{\small}
  \SetAlCapNameSty{textbf}
  \SetAlgoCaptionSeparator{\unskip\hspace*{\ccwd}}
  %
  % 设置算法清单的格式
  \renewcommand\listofalgocfs{%
    \ifxust@degree@graduate
    \cleardoublepage
    \fi
    \xust@chapter{\listalgorithmcfname}%
    \@starttoc{loa}%
  }
  \titlecontents{algocf}
    [2.3em]{\normalsize}
    {\contentslabel{2.3em}}{}
    {\xust@leaders\contentspage}
  \contentsuse{algocf}{loa}
  \renewcommand{\thealgocf}{\arabic{chapter}-\arabic{algocf}}
}


% \subsubsection{\pkg{nomencl} 宏包}

\AtEndOfPackageFile*{nomencl}{
  \let\nomname\xust@notation@name
  \def\thenomenclature{%
    \ifxust@degree@graduate
      \cleardoublepage
      \pagestyle{headings}%
    \fi
    \xust@chapter{\xust@notation@name}%
    \nompreamble
    \list{}{%
      \labelwidth\nom@tempdim
      \leftmargin\labelwidth
      \advance\leftmargin\labelsep
      \itemsep\nomitemsep
      \let\makelabel\nomlabel}}
  \def\endthenomenclature{%
    \endlist
    \nompostamble
    \ifxust@degree@graduate
      \clearpage
      \pagestyle{plain}%
    \fi
  }
}


% \subsubsection{\pkg{siunitx} 宏包}

\AtEndOfPackageFile*{siunitx}{
  \sisetup{
    group-minimum-digits = 4,
    separate-uncertainty = true,
    inter-unit-product   = \ensuremath{{}\cdot{}},
  }
  \ifxust@language@chinese
    \sisetup{
      list-final-separator = { 和 },
      list-pair-separator  = { 和 },
      range-phrase         = {～},
    }
  \fi
}

% \subsubsection{\pkg{chapterbib} 宏包}

\AtEndOfPackageFile*{chapterbib}{
  \renewcommand\bibsection{%
    \ctexset{section/numbering=false}%
    \section{\bibname}%
    \ctexset{section/numbering=true}%
  }
}
