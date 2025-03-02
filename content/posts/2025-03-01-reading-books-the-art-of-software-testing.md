---
title: "「ソフトウェア・テストの技法 第2版」を読んだ"
date: 2025-03-01T13:25:52+09:00
tags: [技読録]
---
「ソフトウェア・テストの技法 第2版」はその名前の通りソフトウェア・テストについて書かれた書籍だ。第1版は1980年、第2版は2006年の出版と、ソフトウェア業界的には非常に古い本であるが、未だに読まれているらしい。いわゆる古典的名著か。

<div class="amazlet-box" style="margin-bottom:0px;">
    <div class="amazlet-image" style="float:left;margin:0px 12px 1px 0px;">
        <a href="https://tatsu-zine.com/books/the-art-of-software-testing" name="amazletlink" target="_blank">
            <img src="https://tatsu-zine.com/images/books/1044/cover_s.jpg" alt="ソフトウェア・テストの技法　第2版" title="ソフトウェア・テストの技法　第2版" style="border: none;" />
        </a>
    </div>
    <div class="amazlet-info" style="line-height:120%;margin-bottom:10px">
        <div class="amazlet-name" style="margin-bottom:10px;line-height:120%">
            <a href="https://tatsu-zine.com/books/the-art-of-software-testing" name="amazletlink" target="_blank">ソフトウェア・テストの技法　第2版【電子書籍】</a>
        </div>
        <div class="amazlet-detail">Glenford J. Myers, Tom Badgett, Todd M. Thomas, Corey Sandler(著), 長尾真(監訳), 松尾正信(訳)<br />近代科学社<br />発行日: 2019-06-04<br />対応フォーマット: PDF<br /></div>
        <div class="amazlet-sub-info" style="float:left;">
            <div class="amazlet-link" style="margin-top:5px">
                <a href="https://tatsu-zine.com/books/the-art-of-software-testing" name="amazletlink" target="_blank">詳細を見る</a>
            </div>
        </div>
    </div>
    <div class="amazlet-footer" style="clear:left"></div>
</div>

私は大学で情報工学を学んで、就職後はソフトウェア開発に関わってきた。そんな中、ソフトウェア・テストのみを取り上げた書籍を読んだことがあまりなかった[^1]。テストフレームワークや CI/CD は頻繁に関する話題はよく目にするが、ソフトウェア・テストを詳説する専門書はあまり見かけない気がする。本著が名著故に競合が現れないのか、それともソフトウェア・テストが比較的興味を持たれにくい領域だからだろうか。

本著は9章構成であるが、4章まで読んで中断した。そこまで読むだけでも有益だったし、もう一度読み直したいと思った。今の段階でも十分に良い書籍だと思ったので、読んだところまで紹介する。

2章「プログラム・テストの心理学と経済学」はとても教訓に満ちた内容だ。ソフトウェア・テストでは得てして可能な限りの入出力を検証しがちだが、限られた時間的、人員的、資金的リソースの中で可能なテストは限られている。そうした制約の中で、最小のコストで最大の効果を得るためのテストをする意義が述べられている。もうちょっと若い時に読みたかった。

4章「テスト・ケースの設計」はどんなことをどんな風にテストするかを解説している。テスト対象を分析する基本的な手法（原因-結果グラフ、限界値分析等）を、具体的な事例を交えながら説明している。この章は個人的に難しく感じており、躓いてしまった。せっかく具体例を挙げているので、読み直して分析をなぞりながら理解したいと思っている。これは宿題だ。

[^1]:「テスト駆動開発による組み込みプログラミング」くらいだろうか
