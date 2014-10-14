staging:
	git pull --all && \
	rsync -azP {*.html,css,js,images,fonts} staging.billo.systems:/var/www/billo/

publish:
	git commit -a && git push --all
