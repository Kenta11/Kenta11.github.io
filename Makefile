.PHONY: all clean

all:
	jekyll serve

create-post:
	touch _posts/$$(date "+%Y-%m-%d")-sample.md

clean:
	rm -rf _site
