staging:
	@#scp -r *.html js css images fonts staging.billo.systems:/var/www/billo/
	rsync -azP {*.html,css,js,images,fonts} staging.billo.systems:/var/www/billo/
