<h1 align="center">Frizz</h2>

<h4 align="center"><strong>CRLF Injection Finder</strong></h4>

<p align="center">
  <a href="#instalation-">Instalation</a> •
  <a href="#examples-">Examples</a>
</p>

<p align="center">
  <img border="0" draggable="false" src="https://cdn.discordapp.com/attachments/876919540682989609/962452079052480592/unknown.png" alt="Frizz Program Logo">
</p>

<hr>

## Instalation <br>

- From source: <br>
**- Requires go1.17**

```bash
go install github.com/ferreiraklet/frizz@latest
```

- From git clone: <br>

```bash
git clone https://github.com/ferreiraklet/frizz
cd frizz/
go build .
sudo mv frizz /usr/local/bin/
frizz -h
```

## Examples <br>

```bash
$ echo "http://127.0.0.1:8080/?q=%0d%0aSet-Cookie:crlf=injection" | frizz -payload "crlf=injection"

$ echo "http://127.0.0.1:8080/?q=%0d%0aSet-Cookie:crlf=injection" | frizz -payload "crlf=injection" -H "Customheader1: value1;cheader2: value2"

$ echo "http://127.0.0.1:8080/?q=%0d%0aSet-Cookie:crlf=injection" | frizz -payload "crlf=injection" --proxy "http://yourproxy"

$ echo "http://127.0.0.1:8080/?q=%0d%0aSet-Cookie:crlf=injection" | frizz -payload "crlf=injection" --only-poc
```

<br>

## Check out some of my other programs <br>

> [Nilo](https://github.com/ferreiraklet/nilo) - Checks if URL has status 200

> [AiriXSS](https://github.com/ferreiraklet/airixss) - Checks for reflected parameters

> [Jeeves](https://github.com/ferreiraklet/jeeves) - SQL Injection Finder
