# ru-latin-transliterator
Transliterate russian latin to cyrillic on macOS. The script follows [this](https://meganorm.ru/mega_doc/norm/gost_gosudarstvennyj-standart/21/gost_7_79-2000_iso_9-95_mezhgosudarstvennyy_standart_sistema.html) GOST-B standart

- app (or terminal) must be added to Accessibility ("Device Control" in macOS 27+)
- accessibility is not always available (e.g. in chrome)

```
swiftc -O gost-hotkey.swift -o gost-hotkey; ./gost-hotkey
```

## Transliteration mappings

| Latin | Cyrillic |
| --- | --- |
| `shh` | щ |
| `sh` | ш |
| `ch` | ч |
| `zh` | ж |
| `cz` | ц |
| `yo` | ё |
| `yu` | ю |
| `ya` | я |
| `y'` | ы |
| `e'` | э |
| `''` | ъ |
| `kh` | х |
| `a` | а |
| `b` | б |
| `c` | ц |
| `d` | д |
| `e` | е |
| `f` | ф |
| `g` | г |
| `h` | х |
| `i` | и |
| `j` | й |
| `k` | к |
| `l` | л |
| `m` | м |
| `n` | н |
| `o` | о |
| `p` | п |
| `q` | щ |
| `r` | р |
| `s` | с |
| `t` | т |
| `u` | у |
| `v` | в |
| `w` | ы |
| `x` | х |
| `y` | ы |
| `z` | з |
| `'` | ь |
