import js.*;
import jQuery.*;
using StringTools;

class ContentScript {
	static function processGithub():Void {
		var lastHref = "";
		Browser.window.setInterval(function() {
			if (lastHref != Browser.location.href) {
				lastHref = Browser.location.href;
				var purl:String = new JQuery(".frame[data-type='blob']").data("permalink-url");
				if (Browser.location.pathname.split("/")[3] == "blob" && Browser.location.pathname.endsWith(".hx")) {
					var loadInt = null;
					loadInt = Browser.window.setInterval(function() {
						var hl = new JQuery("#files .highlight");
						if (hl.length > 0) {
							var container = hl.parent();
							container
								.data("pygmentx-original", container.html())
								.load('http://pygmentx.onthewings.net/?url=${("https://github.com" + new JQuery("#raw-url").attr("href")).urlEncode()} .highlight',
									function(){
										container
											.data("pygmentx-new", container.html())
											.data("pygmentx-current", "pygmentx-new");
										
										new JQuery("<a href='#' class='button minibutton'>Toggle pygmentx</a>")
											.click(function(evt:Event){
												if (container.data("pygmentx-current") == "pygmentx-new") {
													container.html(container.data("pygmentx-original"));
													container.data("pygmentx-current", "pygmentx-original");
												} else {
													container.html(container.data("pygmentx-new"));
													container.data("pygmentx-current", "pygmentx-new");
												}
												evt.preventDefault();
											})
											.appendTo("#files .meta .button-group");
									}
								);
							Browser.window.clearInterval(loadInt);
						}
					}, 50);
				}
			}
		}, 100);
	}
	
	static function processGist():Void {
		var lastHref = "";
		Browser.window.setInterval(function() {
			if (lastHref != Browser.location.href) {
				lastHref = Browser.location.href;
				var path = Browser.location.pathname.split("/");
				if (path.length >= 3 && path[2] != "") { //inside a gist
					var loadInt = null;
					loadInt = Browser.window.setInterval(function() {
						new JQuery(".column.files .file-box").each(function(i, e){	
							Browser.window.clearInterval(loadInt);
							
							var filebox = new JQuery(e);
							var rawurl = filebox.find(".raw-url").attr("href");
							if (rawurl.endsWith(".hx")) {
								var container = filebox.find(".line-pre");
								container
									.data("pygmentx-original", container.html())
									.load('http://pygmentx.onthewings.net/?url=${("https://gist.github.com" + rawurl).urlEncode() + "&cssclass=pygmentx"} .pygmentx',
										function() {
											container
												.data("pygmentx-new", container.html())
												.data("pygmentx-current", "pygmentx-new");
											
											new JQuery("<li><a href='#' class='file-actions-button'>Toggle pygmentx</a></li>")
												.click(function(evt:Event){
													if (container.data("pygmentx-current") == "pygmentx-new") {
														container.html(container.data("pygmentx-original"));
														container.data("pygmentx-current", "pygmentx-original");
													} else {
														container.html(container.data("pygmentx-new"));
														container.data("pygmentx-current", "pygmentx-new");
													}
													evt.preventDefault();
												})
												.appendTo(filebox.find(".meta .button-group"));
										}
									);
							}
						});
					}, 100);
				}
			}
		}, 100);
	}
	
	static function main():Void {
		switch (Browser.location.hostname) {
			case "github.com":
				processGithub();
			case "gist.github.com":
				processGist();
		}
	}
}