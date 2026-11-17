# tcaptcha

`tcaptcha` generates PNG CAPTCHA challenges for Tcl 8.6 and Tcl 9. It uses
`tclgd` for images, Tink for keyed verification, and `thashlib` 0.1.0 or newer
for cryptographic randomness. The package is MIT licensed.

The latest recipe targets the public `jerily/tcaptcha` release `v1.0.0`.
Its source URL is pinned to that Git tag.

After installation, run the example through its `file` script reference:

```sh
ttrek run -package tcaptcha -script demo
ttrek run -package tcaptcha -script demo -- captcha.png 6 true
ttrek run -package tcaptcha -script demo -- digits.png 8 false
```

The example writes a PNG without overwriting an existing file, prompts for its
characters, and checks the answer. Length accepts 4–12 characters; `false` selects
digits only. Its temporary key is only for the demonstration. Applications must
retain their keys, store challenge state on the server, consume it atomically,
and enforce expiry and attempt limits.
