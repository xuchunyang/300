# 《唐诗三百首》数据

```
$ jq .[1] 300.json
{
  "id": 2,
  "contents": "兰叶春葳蕤，桂华秋皎洁。\n欣欣此生意，自尔为佳节。\n谁知林栖者，闻风坐相悦。\n草木有本心，何求美人折？",
  "type": "五言古诗",
  "author": "张九龄",
  "title": "感遇四首之二"
}

$ jq -r '.[] | select(.title == "相思") | .contents + " by " + .author' 300.json
红豆生南国，春来发几枝？
愿君多采撷，此物最相思。 by 王维
```

## 数据来源

http://www.shiku.org/shiku/gs/tangdai.htm

## Long Live the Emacs

李白《长干行》

    M-x @300 李白 长干行

随机一首诗

    M-x @300-random

更多随机

    ;; 随机一首诗
    (seq-random-elt (@300-filter nil nil nil))
    ;; 随机一首李白的诗
    (seq-random-elt (@300-filter "李白" nil nil))
    ;; 随机一首五言绝句
    (seq-random-elt (@300-filter nil nil "五言绝句"))
