import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/common_uis.dart';
import 'package:tsukimisou/markdown_parser.dart';

// These tests are extracted from CommonMark spec 0.31.2 by John MacFarlane,
// licended under CC-BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/).
List<String> _markdownTests = [
  '→foo→baz→→bim',
  '  →foo→baz→→bim',
  '    a→a\n    ὐ→a',
  '  - foo\n\n→bar',
  '- foo\n\n→→bar',
  '>→→foo',
  '-→→foo',
  '    foo\n→bar',
  ' - foo\n   - bar\n→ - baz',
  '#→Foo',
  '*→*→*→',
  '\\!\\"\\#\\\$\\%\\&\\\'\\(\\)\\*\\+\\,\\-\\.\\/\\:\\;\\<\\=\\>\\?\\@\\[\\\\\\]\\^\\_\\`\\{\\|\\}\\~',
  '\\→\\A\\a\\ \\3\\φ\\«',
  '\\*not emphasized*\n\\<br/> not a tag\n\\[not a link](/foo)\n\\`not code`\n1\\. not a list\n\\* not a list\n\\# not a heading\n\\[foo]: /url "not a reference"\n\\&ouml; not a character entity',
  '\\\\*emphasis*',
  'foo\\\nbar',
  '`` \\[\\` ``',
  '    \\[\\]',
  '~~~\n\\[\\]\n~~~',
  '<https://example.com?find=\\*>',
  '<a href="/bar\\/)">',
  '[foo](/bar\\* "ti\\*tle")',
  '[foo]\n\n[foo]: /bar\\* "ti\\*tle"',
  '``` foo\\+bar\nfoo\n```',
  '&nbsp; &amp; &copy; &AElig; &Dcaron;\n&frac34; &HilbertSpace; &DifferentialD;\n&ClockwiseContourIntegral; &ngE;',
  '&#35; &#1234; &#992; &#0;',
  '&#X22; &#XD06; &#xcab;',
  '&nbsp &x; &#; &#x;\n&#87654321;\n&#abcdef0;\n&ThisIsNotDefined; &hi?;',
  '&copy',
  '&MadeUpEntity;',
  '<a href="&ouml;&ouml;.html">',
  '[foo](/f&ouml;&ouml; "f&ouml;&ouml;")',
  '[foo]\n\n[foo]: /f&ouml;&ouml; "f&ouml;&ouml;"',
  '``` f&ouml;&ouml;\nfoo\n```',
  '`f&ouml;&ouml;`',
  '    f&ouml;f&ouml;',
  '&#42;foo&#42;\n*foo*',
  '&#42; foo\n\n* foo',
  'foo&#10;&#10;bar',
  '&#9;foo',
  '[a](url &quot;tit&quot;)',
  '- `one\n- two`',
  '***\n---\n___',
  '+++',
  '===',
  '--\n**\n__',
  ' ***\n  ***\n   ***',
  '    ***',
  'Foo\n    ***',
  '_____________________________________',
  ' - - -',
  ' **  * ** * ** * **',
  '-     -      -      -',
  '- - - -    ',
  '_ _ _ _ a\n\na------\n\n---a---',
  ' *-*',
  '- foo\n***\n- bar',
  'Foo\n***\nbar',
  'Foo\n---\nbar',
  '* Foo\n* * *\n* Bar',
  '- Foo\n- * * *',
  '# foo\n## foo\n### foo\n#### foo\n##### foo\n###### foo',
  '####### foo',
  '#5 bolt\n\n#hashtag',
  '\\## foo',
  '# foo *bar* \\*baz\\*',
  '#                  foo                     ',
  ' ### foo\n  ## foo\n   # foo',
  '    # foo',
  'foo\n    # bar',
  '## foo ##\n  ###   bar    ###',
  '# foo ##################################\n##### foo ##',
  '### foo ###     ',
  '### foo ### b',
  '# foo#',
  '### foo \\###\n## foo #\\##\n# foo \\#',
  '****\n## foo\n****',
  'Foo bar\n# baz\nBar foo',
  '## \n#\n### ###',
  'Foo *bar*\n=========\n\nFoo *bar*\n---------',
  'Foo *bar\nbaz*\n====',
  '  Foo *bar\nbaz*→\n====',
  'Foo\n-------------------------\n\nFoo\n=',
  '   Foo\n---\n\n  Foo\n-----\n\n  Foo\n  ===',
  '    Foo\n    ---\n\n    Foo\n---',
  'Foo\n   ----      ',
  'Foo\n    ---',
  'Foo\n= =\n\nFoo\n--- -',
  'Foo  \n-----',
  'Foo\\\n----',
  '`Foo\n----\n`\n\n<a title="a lot\n---\nof dashes"/>',
  '> Foo\n---',
  '> foo\nbar\n===',
  '- Foo\n---',
  'Foo\nBar\n---',
  '---\nFoo\n---\nBar\n---\nBaz',
  '\n====',
  '---\n---',
  '- foo\n-----',
  '    foo\n---',
  '> foo\n-----',
  '\\> foo\n------',
  'Foo\n\nbar\n---\nbaz',
  'Foo\nbar\n\n---\n\nbaz',
  'Foo\nbar\n* * *\nbaz',
  'Foo\nbar\n\\---\nbaz',
  '    a simple\n      indented code block',
  '  - foo\n\n    bar',
  '1.  foo\n\n    - bar',
  '    <a/>\n    *hi*\n\n    - one',
  '    chunk1\n\n    chunk2\n  \n \n \n    chunk3',
  '    chunk1\n      \n      chunk2',
  'Foo\n    bar\n',
  '    foo\nbar',
  '# Heading\n    foo\nHeading\n------\n    foo\n----',
  '        foo\n    bar',
  '\n    \n    foo\n    \n',
  '    foo  ',
  '```\n<\n >\n```',
  '~~~\n<\n >\n~~~',
  '``\nfoo\n``',
  '```\naaa\n~~~\n```',
  '~~~\naaa\n```\n~~~',
  '````\naaa\n```\n``````',
  '~~~~\naaa\n~~~\n~~~~',
  '```',
  '`````\n\n```\naaa',
  '> ```\n> aaa\n\nbbb',
  '```\n\n  \n```',
  '```\n```',
  ' ```\n aaa\naaa\n```',
  '  ```\naaa\n  aaa\naaa\n  ```',
  '   ```\n   aaa\n    aaa\n  aaa\n   ```',
  '    ```\n    aaa\n    ```',
  '```\naaa\n  ```',
  '   ```\naaa\n  ```',
  '```\naaa\n    ```',
  '``` ```\naaa',
  '~~~~~~\naaa\n~~~ ~~',
  'foo\n```\nbar\n```\nbaz',
  'foo\n---\n~~~\nbar\n~~~\n# baz',
  '```ruby\ndef foo(x)\n  return 3\nend\n```',
  '~~~~    ruby startline=3 \$%@#\$\ndef foo(x)\n  return 3\nend\n~~~~~~~',
  '````;\n````',
  '``` aa ```\nfoo',
  '~~~ aa ``` ~~~\nfoo\n~~~',
  '```\n``` aaa\n```',
  '<table><tr><td>\n<pre>\n**Hello**,\n\n_world_.\n</pre>\n</td></tr></table>',
  '<table>\n  <tr>\n    <td>\n           hi\n    </td>\n  </tr>\n</table>\n\nokay.',
  ' <div>\n  *hello*\n         <foo><a>',
  '</div>\n*foo*',
  '<DIV CLASS="foo">\n\n*Markdown*\n\n</DIV>',
  '<div id="foo"\n  class="bar">\n</div>',
  '<div id="foo" class="bar\n  baz">\n</div>',
  '<div>\n*foo*\n\n*bar*',
  '<div id="foo"\n*hi*',
  '<div class\nfoo',
  '<div *???-&&&-<---\n*foo*',
  '<div><a href="bar">*foo*</a></div>',
  '<table><tr><td>\nfoo\n</td></tr></table>',
  '<div></div>\n``` c\nint x = 33;\n```',
  '<div\n> not quoted text',
  '<a href="foo">\n*bar*\n</a>',
  '<Warning>\n*bar*\n</Warning>',
  '<i class="foo">\n*bar*\n</i>',
  '</ins>\n*bar*',
  '<del>\n*foo*\n</del>',
  '<del>\n\n*foo*\n\n</del>',
  '<del>*foo*</del>',
  '<del\nclass="foo">\n*foo*\n</del>',
  '<pre language="haskell"><code>\nimport Text.HTML.TagSoup\n\nmain :: IO ()\nmain = print \$ parseTags tags\n</code></pre>\nokay',
  '<script type="text/javascript">\n// JavaScript example\n\ndocument.getElementById("demo").innerHTML = "Hello JavaScript!";\n</script>\nokay',
  '<textarea>\n\n*foo*\n\n_bar_\n\n</textarea>',
  '<style\n  type="text/css">\nh1 {color:red;}\n\np {color:blue;}\n</style>\nokay',
  '<style\n  type="text/css">\n\nfoo',
  '> <div>\n> foo\n\nbar',
  '- <div>\n- foo',
  '<style>p{color:red;}</style>\n*foo*',
  '<!-- foo -->*bar*\n*baz*',
  '<script>\nfoo\n</script>1. *bar*',
  '<!-- Foo\n\nbar\n   baz -->\nokay',
  '<?php\n\n  echo \'>\';\n\n?>\nokay',
  '<!DOCTYPE html>',
  '<![CDATA[\nfunction matchwo(a,b)\n{\n  if (a < b && a < 0) then {\n    return 1;\n\n  } else {\n\n    return 0;\n  }\n}\n]]>\nokay',
  '  <!-- foo -->\n\n    <!-- foo -->',
  '  <div>\n\n    <div>',
  'Foo\n<div>\nbar\n</div>',
  '<div>\nbar\n</div>\n*foo*',
  'Foo\n<a href="bar">\nbaz',
  '<div>\n\n*Emphasized* text.\n\n</div>',
  '<div>\n*Emphasized* text.\n</div>',
  '<table>\n\n<tr>\n\n<td>\nHi\n</td>\n\n</tr>\n\n</table>',
  '<table>\n\n  <tr>\n\n    <td>\n      Hi\n    </td>\n\n  </tr>\n\n</table>',
  '[foo]: /url "title"\n\n[foo]',
  '   [foo]: \n      /url  \n           \'the title\'  \n\n[foo]',
  '[Foo*bar\\]]:my_(url) \'title (with parens)\'\n\n[Foo*bar\\]]',
  '[Foo bar]:\n<my url>\n\'title\'\n\n[Foo bar]',
  '[foo]: /url \'\ntitle\nline1\nline2\n\'\n\n[foo]',
  '[foo]: /url \'title\n\nwith blank line\'\n\n[foo]',
  '[foo]:\n/url\n\n[foo]',
  '[foo]:\n\n[foo]',
  '[foo]: <>\n\n[foo]',
  '[foo]: <bar>(baz)\n\n[foo]',
  '[foo]: /url\\bar\\*baz "foo\\"bar\\baz"\n\n[foo]',
  '[foo]\n\n[foo]: url',
  '[foo]\n\n[foo]: first\n[foo]: second',
  '[FOO]: /url\n\n[Foo]',
  '[ΑΓΩ]: /φου\n\n[αγω]',
  '[foo]: /url',
  '[\nfoo\n]: /url\nbar',
  '[foo]: /url "title" ok',
  '[foo]: /url\n"title" ok',
  '    [foo]: /url "title"\n\n[foo]',
  '```\n[foo]: /url\n```\n\n[foo]',
  'Foo\n[bar]: /baz\n\n[bar]',
  '# [Foo]\n[foo]: /url\n> bar',
  '[foo]: /url\nbar\n===\n[foo]',
  '[foo]: /url\n===\n[foo]',
  '[foo]: /foo-url "foo"\n[bar]: /bar-url\n  "bar"\n[baz]: /baz-url\n\n[foo],\n[bar],\n[baz]',
  '[foo]\n\n> [foo]: /url',
  'aaa\n\nbbb',
  'aaa\nbbb\n\nccc\nddd',
  'aaa\n\n\nbbb',
  '  aaa\n bbb',
  'aaa\n             bbb\n                                       ccc',
  '   aaa\nbbb',
  '    aaa\nbbb',
  'aaa     \nbbb     ',
  '  \n\naaa\n  \n\n# aaa\n\n  ',
  '> # Foo\n> bar\n> baz',
  '># Foo\n>bar\n> baz',
  '   > # Foo\n   > bar\n > baz',
  '    > # Foo\n    > bar\n    > baz',
  '> # Foo\n> bar\nbaz',
  '> bar\nbaz\n> foo',
  '> foo\n---',
  '> - foo\n- bar',
  '>     foo\n    bar',
  '> ```\nfoo\n```',
  '> foo\n    - bar',
  '>',
  '>\n>  \n> ',
  '>\n> foo\n>  ',
  '> foo\n\n> bar',
  '> foo\n> bar',
  '> foo\n>\n> bar',
  'foo\n> bar',
  '> aaa\n***\n> bbb',
  '> bar\nbaz',
  '> bar\n\nbaz',
  '> bar\n>\nbaz',
  '> > > foo\nbar',
  '>>> foo\n> bar\n>>baz',
  '>     code\n\n>    not code',
  'A paragraph\nwith two lines.\n\n    indented code\n\n> A block quote.',
  '1.  A paragraph\n    with two lines.\n\n        indented code\n\n    > A block quote.',
  '- one\n\n two',
  '- one\n\n  two',
  ' -    one\n\n     two',
  ' -    one\n\n      two',
  '   > > 1.  one\n>>\n>>     two',
  '>>- one\n>>\n  >  > two',
  '-one\n\n2.two',
  '- foo\n\n\n  bar',
  '1.  foo\n\n    ```\n    bar\n    ```\n\n    baz\n\n    > bam',
  '- Foo\n\n      bar\n\n\n      baz',
  '123456789. ok',
  '1234567890. not ok',
  '0. ok',
  '003. ok',
  '-1. not ok',
  '- foo\n\n      bar',
  '  10.  foo\n\n           bar',
  '    indented code\n\nparagraph\n\n    more code',
  '1.     indented code\n\n   paragraph\n\n       more code',
  '1.      indented code\n\n   paragraph\n\n       more code',
  '   foo\n\nbar',
  '-    foo\n\n  bar',
  '-  foo\n\n   bar',
  '-\n  foo\n-\n  ```\n  bar\n  ```\n-\n      baz',
  '-   \n  foo',
  '-\n\n  foo',
  '- foo\n-\n- bar',
  '- foo\n-   \n- bar',
  '1. foo\n2.\n3. bar',
  '*',
  'foo\n*\n\nfoo\n1.',
  ' 1.  A paragraph\n     with two lines.\n\n         indented code\n\n     > A block quote.',
  '  1.  A paragraph\n      with two lines.\n\n          indented code\n\n      > A block quote.',
  '   1.  A paragraph\n       with two lines.\n\n           indented code\n\n       > A block quote.',
  '    1.  A paragraph\n        with two lines.\n\n            indented code\n\n        > A block quote.',
  '  1.  A paragraph\nwith two lines.\n\n          indented code\n\n      > A block quote.',
  '  1.  A paragraph\n    with two lines.',
  '> 1. > Blockquote\ncontinued here.',
  '> 1. > Blockquote\n> continued here.',
  '- foo\n  - bar\n    - baz\n      - boo',
  '- foo\n - bar\n  - baz\n   - boo',
  '10) foo\n    - bar',
  '10) foo\n   - bar',
  '- - foo',
  '1. - 2. foo',
  '- # Foo\n- Bar\n  ---\n  baz',
  '- foo\n- bar\n+ baz',
  '1. foo\n2. bar\n3) baz',
  'Foo\n- bar\n- baz',
  'The number of windows in my house is\n14.  The number of doors is 6.',
  'The number of windows in my house is\n1.  The number of doors is 6.',
  '- foo\n\n- bar\n\n\n- baz',
  '- foo\n  - bar\n    - baz\n\n\n      bim',
  '- foo\n- bar\n\n<!-- -->\n\n- baz\n- bim',
  '-   foo\n\n    notcode\n\n-   foo\n\n<!-- -->\n\n    code',
  '- a\n - b\n  - c\n   - d\n  - e\n - f\n- g',
  '1. a\n\n  2. b\n\n   3. c',
  '- a\n - b\n  - c\n   - d\n    - e',
  '1. a\n\n  2. b\n\n    3. c',
  '- a\n- b\n\n- c',
  '* a\n*\n\n* c',
  '- a\n- b\n\n  c\n- d',
  '- a\n- b\n\n  [ref]: /url\n- d',
  '- a\n- ```\n  b\n\n\n  ```\n- c',
  '- a\n  - b\n\n    c\n- d',
  '* a\n  > b\n  >\n* c',
  '- a\n  > b\n  ```\n  c\n  ```\n- d',
  '- a',
  '- a\n  - b',
  '1. ```\n   foo\n   ```\n\n   bar',
  '* foo\n  * bar\n\n  baz',
  '- a\n  - b\n  - c\n\n- d\n  - e\n  - f',
  '`hi`lo`',
  '`foo`',
  '`` foo ` bar ``',
  '` `` `',
  '`  ``  `',
  '` a`',
  '` b `',
  '` `\n`  `',
  '``\nfoo\nbar  \nbaz\n``',
  '``\nfoo \n``',
  '`foo   bar \nbaz`',
  '`foo\\`bar`',
  '``foo`bar``',
  '` foo `` bar `',
  '*foo`*`',
  '[not a `link](/foo`)',
  '`<a href="`">`',
  '<a href="`">`',
  '`<https://foo.bar.`baz>`',
  '<https://foo.bar.`baz>`',
  '```foo``',
  '`foo',
  '`foo``bar``',
  '*foo bar*',
  'a * foo bar*',
  'a*"foo"*',
  '* a *',
  '*\$*alpha.\n\n*£*bravo.\n\n*€*charlie.\n\n*𞋿*delta.',
  'foo*bar*',
  '5*6*78',
  '_foo bar_',
  '_ foo bar_',
  'a_"foo"_',
  'foo_bar_',
  '5_6_78',
  'пристаням_стремятся_',
  'aa_"bb"_cc',
  'foo-_(bar)_',
  '_foo*',
  '*foo bar *',
  '*foo bar\n*',
  '*(*foo)',
  '*(*foo*)*',
  '*foo*bar',
  '_foo bar _',
  '_(_foo)',
  '_(_foo_)_',
  '_foo_bar',
  '_пристаням_стремятся',
  '_foo_bar_baz_',
  '_(bar)_.',
  '**foo bar**',
  '** foo bar**',
  'a**"foo"**',
  'foo**bar**',
  '__foo bar__',
  '__ foo bar__',
  '__\nfoo bar__',
  'a__"foo"__',
  'foo__bar__',
  '5__6__78',
  'пристаням__стремятся__',
  '__foo, __bar__, baz__',
  'foo-__(bar)__',
  '**foo bar **',
  '**(**foo)',
  '*(**foo**)*',
  '**Gomphocarpus (*Gomphocarpus physocarpus*, syn.\n*Asclepias physocarpa*)**',
  '**foo "*bar*" foo**',
  '**foo**bar',
  '__foo bar __',
  '__(__foo)',
  '_(__foo__)_',
  '__foo__bar',
  '__пристаням__стремятся',
  '__foo__bar__baz__',
  '__(bar)__.',
  '*foo [bar](/url)*',
  '*foo\nbar*',
  '_foo __bar__ baz_',
  '_foo _bar_ baz_',
  '__foo_ bar_',
  '*foo *bar**',
  '*foo **bar** baz*',
  '*foo**bar**baz*',
  '*foo**bar*',
  '***foo** bar*',
  '*foo **bar***',
  '*foo**bar***',
  'foo***bar***baz',
  'foo******bar*********baz',
  '*foo **bar *baz* bim** bop*',
  '*foo [*bar*](/url)*',
  '** is not an empty emphasis',
  '**** is not an empty strong emphasis',
  '**foo [bar](/url)**',
  '**foo\nbar**',
  '__foo _bar_ baz__',
  '__foo __bar__ baz__',
  '____foo__ bar__',
  '**foo **bar****',
  '**foo *bar* baz**',
  '**foo*bar*baz**',
  '***foo* bar**',
  '**foo *bar***',
  '**foo *bar **baz**\nbim* bop**',
  '**foo [*bar*](/url)**',
  '__ is not an empty emphasis',
  '____ is not an empty strong emphasis',
  'foo ***',
  'foo *\\**',
  'foo *_*',
  'foo *****',
  'foo **\\***',
  'foo **_**',
  '**foo*',
  '*foo**',
  '***foo**',
  '****foo*',
  '**foo***',
  '*foo****',
  'foo ___',
  'foo _\\__',
  'foo _*_',
  'foo _____',
  'foo __\\___',
  'foo __*__',
  '__foo_',
  '_foo__',
  '___foo__',
  '____foo_',
  '__foo___',
  '_foo____',
  '**foo**',
  '*_foo_*',
  '__foo__',
  '_*foo*_',
  '****foo****',
  '____foo____',
  '******foo******',
  '***foo***',
  '_____foo_____',
  '*foo _bar* baz_',
  '*foo __bar *baz bim__ bam*',
  '**foo **bar baz**',
  '*foo *bar baz*',
  '*[bar*](/url)',
  '_foo [bar_](/url)',
  '*<img src="foo" title="*"/>',
  '**<a href="**">',
  '__<a href="__">',
  '*a `*`*',
  '_a `_`_',
  '**a<https://foo.bar/?q=**>',
  '__a<https://foo.bar/?q=__>',
  '[link](/uri "title")',
  '[link](/uri)',
  '[](./target.md)',
  '[link]()',
  '[link](<>)',
  '[]()',
  '[link](/my uri)',
  '[link](</my uri>)',
  '[link](foo\nbar)',
  '[link](<foo\nbar>)',
  '[a](<b)c>)',
  '[link](<foo\\>)',
  '[a](<b)c\n[a](<b)c>\n[a](<b>c)',
  '[link](\\(foo\\))',
  '[link](foo(and(bar)))',
  '[link](foo(and(bar))',
  '[link](foo\\(and\\(bar\\))',
  '[link](<foo(and(bar)>)',
  '[link](foo\\)\\:)',
  '[link](#fragment)\n\n[link](https://example.com#fragment)\n\n[link](https://example.com?foo=3#frag)',
  '[link](foo\\bar)',
  '[link](foo%20b&auml;)',
  '[link]("title")',
  '[link](/url "title")\n[link](/url \'title\')\n[link](/url (title))',
  '[link](/url "title \\"&quot;")',
  '[link](/url "title")',
  '[link](/url "title "and" title")',
  '[link](/url \'title "and" title\')',
  '[link](   /uri\n  "title"  )',
  '[link] (/uri)',
  '[link [foo [bar]]](/uri)',
  '[link] bar](/uri)',
  '[link [bar](/uri)',
  '[link \\[bar](/uri)',
  '[link *foo **bar** `#`*](/uri)',
  '[![moon](moon.jpg)](/uri)',
  '[foo [bar](/uri)](/uri)',
  '[foo *[bar [baz](/uri)](/uri)*](/uri)',
  '![[[foo](uri1)](uri2)](uri3)',
  '*[foo*](/uri)',
  '[foo *bar](baz*)',
  '*foo [bar* baz]',
  '[foo <bar attr="](baz)">',
  '[foo`](/uri)`',
  '[foo<https://example.com/?search=](uri)>',
  '[foo][bar]\n\n[bar]: /url "title"',
  '[link [foo [bar]]][ref]\n\n[ref]: /uri',
  '[link \\[bar][ref]\n\n[ref]: /uri',
  '[link *foo **bar** `#`*][ref]\n\n[ref]: /uri',
  '[![moon](moon.jpg)][ref]\n\n[ref]: /uri',
  '[foo [bar](/uri)][ref]\n\n[ref]: /uri',
  '[foo *bar [baz][ref]*][ref]\n\n[ref]: /uri',
  '*[foo*][ref]\n\n[ref]: /uri',
  '[foo *bar][ref]*\n\n[ref]: /uri',
  '[foo <bar attr="][ref]">\n\n[ref]: /uri',
  '[foo`][ref]`\n\n[ref]: /uri',
  '[foo<https://example.com/?search=][ref]>\n\n[ref]: /uri',
  '[foo][BaR]\n\n[bar]: /url "title"',
  '[ẞ]\n\n[SS]: /url',
  '[Foo\n  bar]: /url\n\n[Baz][Foo bar]',
  '[foo] [bar]\n\n[bar]: /url "title"',
  '[foo]\n[bar]\n\n[bar]: /url "title"',
  '[foo]: /url1\n\n[foo]: /url2\n\n[bar][foo]',
  '[bar][foo\\!]\n\n[foo!]: /url',
  '[foo][ref[]\n\n[ref[]: /uri',
  '[foo][ref[bar]]\n\n[ref[bar]]: /uri',
  '[[[foo]]]\n\n[[[foo]]]: /url',
  '[foo][ref\\[]\n\n[ref\\[]: /uri',
  '[bar\\\\]: /uri\n\n[bar\\\\]',
  '[]\n\n[]: /uri',
  '[\n ]\n\n[\n ]: /uri',
  '[foo][]\n\n[foo]: /url "title"',
  '[*foo* bar][]\n\n[*foo* bar]: /url "title"',
  '[Foo][]\n\n[foo]: /url "title"',
  '[foo] \n[]\n\n[foo]: /url "title"',
  '[foo]\n\n[foo]: /url "title"',
  '[*foo* bar]\n\n[*foo* bar]: /url "title"',
  '[[*foo* bar]]\n\n[*foo* bar]: /url "title"',
  '[[bar [foo]\n\n[foo]: /url',
  '[Foo]\n\n[foo]: /url "title"',
  '[foo] bar\n\n[foo]: /url',
  '\\[foo]\n\n[foo]: /url "title"',
  '[foo*]: /url\n\n*[foo*]',
  '[foo][bar]\n\n[foo]: /url1\n[bar]: /url2',
  '[foo][]\n\n[foo]: /url1',
  '[foo]()\n\n[foo]: /url1',
  '[foo](not a link)\n\n[foo]: /url1',
  '[foo][bar][baz]\n\n[baz]: /url',
  '[foo][bar][baz]\n\n[baz]: /url1\n[bar]: /url2',
  '[foo][bar][baz]\n\n[baz]: /url1\n[foo]: /url2',
  '![foo](/url "title")',
  '![foo *bar*]\n\n[foo *bar*]: train.jpg "train & tracks"',
  '![foo ![bar](/url)](/url2)',
  '![foo [bar](/url)](/url2)',
  '![foo *bar*][]\n\n[foo *bar*]: train.jpg "train & tracks"',
  '![foo *bar*][foobar]\n\n[FOOBAR]: train.jpg "train & tracks"',
  '![foo](train.jpg)',
  'My ![foo bar](/path/to/train.jpg  "title"   )',
  '![foo](<url>)',
  '![](/url)',
  '![foo][bar]\n\n[bar]: /url',
  '![foo][bar]\n\n[BAR]: /url',
  '![foo][]\n\n[foo]: /url "title"',
  '![*foo* bar][]\n\n[*foo* bar]: /url "title"',
  '![Foo][]\n\n[foo]: /url "title"',
  '![foo] \n[]\n\n[foo]: /url "title"',
  '![foo]\n\n[foo]: /url "title"',
  '![*foo* bar]\n\n[*foo* bar]: /url "title"',
  '![[foo]]\n\n[[foo]]: /url "title"',
  '![Foo]\n\n[foo]: /url "title"',
  '!\\[foo]\n\n[foo]: /url "title"',
  '\\![foo]\n\n[foo]: /url "title"',
  '<http://foo.bar.baz>',
  '<https://foo.bar.baz/test?q=hello&id=22&boolean>',
  '<irc://foo.bar:2233/baz>',
  '<MAILTO:FOO@BAR.BAZ>',
  '<a+b+c:d>',
  '<made-up-scheme://foo,bar>',
  '<https://../>',
  '<localhost:5001/foo>',
  '<https://foo.bar/baz bim>',
  '<https://example.com/\\[\\>',
  '<foo@bar.example.com>',
  '<foo+special@Bar.baz-bar0.com>',
  '<foo\\+@bar.example.com>',
  '<>',
  '< https://foo.bar >',
  '<m:abc>',
  '<foo.bar.baz>',
  'https://example.com',
  'foo@bar.example.com',
  '<a><bab><c2c>',
  '<a/><b2/>',
  '<a  /><b2\ndata="foo" >',
  '<a foo="bar" bam = \'baz <em>"</em>\'\n_boolean zoop:33=zoop:33 />',
  'Foo <responsive-image src="foo.jpg" />',
  '<33> <__>',
  '<a h*#ref="hi">',
  '<a href="hi\'> <a href=hi\'>',
  '< a><\nfoo><bar/ >\n<foo bar=baz\nbim!bop />',
  '<a href=\'bar\'title=title>',
  '</a></foo >',
  '</a href="foo">',
  'foo <!-- this is a --\ncomment - with hyphens -->',
  'foo <!--> foo -->\n\nfoo <!---> foo -->',
  'foo <?php echo \$a; ?>',
  'foo <!ELEMENT br EMPTY>',
  'foo <![CDATA[>&<]]>',
  'foo <a href="&ouml;">',
  'foo <a href="\\*">',
  '<a href="\\"">',
  '<a\n> quoted text',
  'foo  \nbaz',
  'foo\\\nbaz',
  'foo       \nbaz',
  'foo  \n     bar',
  'foo\\\n     bar',
  '*foo  \nbar*',
  '*foo\\\nbar*',
  '`code  \nspan`',
  '`code\\\nspan`',
  '<a href="foo  \nbar">',
  '<a href="foo\\\nbar">',
  'foo\\',
  'foo  ',
  '### foo\\',
  '### foo  ',
  'foo\nbaz',
  'foo \n baz',
  'hello \$.;\'there',
  'Foo χρῆν',
  'Multiple     spaces'
];

Future<void> init(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Text('This is a test.'),
    ),
  );
}

void main() {
  group('MarkdownParser', () {
    testWidgets('MarkdownParser should be created.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final _ = MarkdownParser(context, '# Hello, World!');
    });

    testWidgets('MarkdownParser should be executable.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '# Hello, World!');
      parser.execute();
    });

    testWidgets('MarkdownParser should create widgets for body texts.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, 'Hello, World!');
      parser.execute();
      final textTheme = parser.textTheme;
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final text = widget as Text;
      final span = text.textSpan as TextSpan;
      expect(span.style, textTheme.bodyMedium);
      expect(span.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for code block texts.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '```\nHello, World!\n```');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final text = widget as Text;
      final span = text.textSpan as TextSpan;
      expect(span.style!.backgroundColor, TsukimisouColors.codeBackground);
      expect(span.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for block quote texts.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '> Hello, World!');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final row = widget as Row;
      expect(row.children[0] is Container, true);
      expect(row.children[1] is SizedBox, true);
      expect(row.children[2] is Flexible, true);
    });

    testWidgets('MarkdownParser should create widgets for strikethrough texts.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '~~Hello, World!~~');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final text = widget as Text;
      final span = text.textSpan as TextSpan;
      final aSpan = span.children![0] as TextSpan;
      expect(aSpan.style!.decoration, TextDecoration.lineThrough);
      expect(aSpan.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for code span texts.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '`Hello, World!`');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final text = widget as Text;
      final span = text.textSpan as TextSpan;
      final aSpan = span.children![0] as TextSpan;
      expect(aSpan.style!.backgroundColor, TsukimisouColors.codeBackground);
      expect(aSpan.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for large healines.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '# Hello, World!');
      parser.execute();
      final textTheme = parser.textTheme;
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final container = widget as Container;
      final text = container.child as Text;
      final span = text.textSpan as TextSpan;
      expect(span.style, textTheme.headlineLarge);
      expect(span.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for medium headlines.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '## Hello, World!');
      parser.execute();
      final textTheme = parser.textTheme;
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final container = widget as Container;
      final text = container.child as Text;
      final span = text.textSpan as TextSpan;
      expect(span.style, textTheme.headlineMedium);
      expect(span.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for small headlines.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '### Hello, World!');
      parser.execute();
      final textTheme = parser.textTheme;
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final container = widget as Container;
      final text = container.child as Text;
      final span = text.textSpan as TextSpan;
      expect(span.style, textTheme.headlineSmall);
      expect(span.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for unordered lists 1.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '* Hello, World!');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final row = widget as Row;
      expect(row.children[0] is SizedBox, true);
      expect(row.children[1] is Flexible, true);
    });

    testWidgets('MarkdownParser should create widgets for unordered lists 2.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '    * Hello, World!');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final row = widget as Row;
      expect(row.children[0] is SizedBox, true);
      expect(row.children[1] is Flexible, true);
    });

    testWidgets('MarkdownParser should create widgets for unordered lists 3.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '        * Hello, World!');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final row = widget as Row;
      expect(row.children[0] is SizedBox, true);
      expect(row.children[1] is Flexible, true);
    });

    testWidgets('MarkdownParser should create widgets for ordered lists.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '1. Hello, World!');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final row = widget as Row;
      expect(row.children[0] is SizedBox, true);
      expect(row.children[1] is Flexible, true);
    });

    testWidgets('MarkdownParser should create widgets for link texts.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final textTheme = Theme.of(context).textTheme;
      final parser =
          MarkdownParser(context, '[Hello, World!](https://www.google.com)');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final text = widget as Text;
      final span = text.textSpan as TextSpan;
      expect(span.style, textTheme.bodyMedium);
      expect(span.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for autolinks.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final textTheme = Theme.of(context).textTheme;
      final parser = MarkdownParser(context, '<https://www.google.com>');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final text = widget as Text;
      final span = text.textSpan as TextSpan;
      expect(span.style, textTheme.bodyMedium);
      expect(span.toPlainText(), 'https://www.google.com');
    });

    testWidgets('MarkdownParser should create widgets for thematic breaks.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '---');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final text = widget as Text;
      final span = text.textSpan as TextSpan;
      final children = span.children!;
      final widgetSpan = children[0] as WidgetSpan;
      final row = widgetSpan.child as Row;
      expect(row.children[0] is SizedBox, true);
      expect(row.children[1] is Expanded, true);
      expect(row.children[2] is SizedBox, true);
    });

    testWidgets('MarkdownParser should create widgets for paragraphs.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, 'Hello, World!\n\nHello, World!');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      expect(column.children.length, 3);
      expect(column.children[1] is SizedBox, true);
    });

    testWidgets('MarkdownParser should parse Markdown texts that extracted from spec.txt.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      for (final line in _markdownTests) {
        final parser = MarkdownParser(context, line);
        parser.execute();
      }
    });
  });
}
