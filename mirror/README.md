# Eina ref1oct
Eina per a fer mirrors de la web del Referèndum d'Autodeterminació de
Catalunya 2017.

---

The Spanish government is pushing the boundaries of human rights and freedom of
speech through their actions against the govenment of Catalunya, and sadly this
has also spread to the net.

Several domains have been censored or blocked, in order to prevent the catalan
government from spreading information about the referendum organization and the
polling stations. They have even attacked staff from the foundation running the
.cat TLD, as a mean to control some of the sites and mirrors with the
information.

This is **stupid** beyond measure, and an attack to both democratic values as
well as right to access to information, so I decided to put together some
duct tape to help spin off mirrors of the site. *Fuck fascism.*

---

## Instructions

Starting a container should be quite straightforward:

```
docker build --pull -t ref1oct:latest .
docker run -dp 80:80 -p 443:443 --name ref1oct  ref1oct
```

The build process takes care of scrapping the official site.

If you see issues downloading the hashed census database, you can
still retrieve missing files calling this after the container has been
built:

```
docker exec -ti ref1oct dump_db --missing
```

You will need to change the port exports if you plan to run this in
non-dedicated environments.


### Configuring SSL with Let's Encrypt

To add support for SSL, you will first need to make sure your site is reachable
from outside, since this will use certbot's automated verification.

With the container running, you just need to run the enable_ssl script
inside the container:

```
docker exec -ti ref1oct enable_ssl my-site-domain.cat my-other-domain.cat
```

You need to specify all the domains you will be using in that command, since
it will rewrite the nginx configuration, as well as request the certificates.


### Updating the scraped content

In order to update the website, all you need to do is to run the
following command (the same one ran during the build process):

```
docker exec -ti ref1oct dump_web
```


**Note**: The entire process is not precisely elegant, and each time you
rebuild the container, it will scrap/download the entire data again, so
take that into account, and just call the two scrap scripts as needed, which
should allow to incrementally update content.

