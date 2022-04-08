<h2 align="center">Baú</h2>

<h4 align="center"><strong>Bash All Urls</strong></h4>

<p align="center">
  <img border="0" draggable="false" src="https://gamehag.com/img/cases/18.png" alt="Spidery Chest">
</p>

<hr>

## Instalation <br>

```console
git clone https://github.com/RodricBr/bau
cd bau/;chmod +x bau
sudo mv bau /usr/local/bin/
bau
```

## Examples <br>

```bash
# Normal use
./bau vulnweb.com -ns "js|svg|png"
./bau vulnweb.com -s "js|php|svg|png|jpeg|jpg"
./bau vulnweb.com -ns
./bau vulnweb.com -s
```

```bash
# Pratical use with XARGS
echo "vulnweb.com" | xargs -I{} bash -c './main.sh {} -ns'
echo "vulnweb.com" | xargs -I{} bash -c './main.sh {} -s "php|js|svg|png"'
```

