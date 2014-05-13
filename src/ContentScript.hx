import js.*;
import js.html.*;
import jQuery.*;
using StringTools;

extern class MutationSummary {
	public function new(config:Dynamic):Void;
}

typedef Summary = {
	projection: Dynamic, 
	added: Array<Node>, 
	removed: Array<Node>, 
	reparented: Array<Node>
};

class ContentScript {
	static function processGithubBlobDiv(blobDiv:DivElement):Void {
		var url = cast (new JQuery("#raw-url")[0], AnchorElement).href;
		// trace(url);
		var container = new JQuery(blobDiv).find(".highlight").parent();
		container
			.data("pygmentx-original", container.html())
			.load('http://pygmentx.onthewings.net/?url=${url} .highlight',
				function(responseText, textStatus, XMLHttpRequest){
					if (textStatus != "success") {
						trace(textStatus);
						trace(responseText);
						return;
					}
					container
						.data("pygmentx-new", container.html())
						.data("pygmentx-current", "pygmentx-new");
					
					new JQuery("<a href='#' class='button minibutton tooltipped tooltipped-s' aria-label='Pygmentx enabled'><span class='label'>Pygmentx</span></a>")
						.click(function(evt:Event){
							if (container.data("pygmentx-current") == "pygmentx-new") {
								container.html(container.data("pygmentx-original"));
								container.data("pygmentx-current", "pygmentx-original");
								new JQuery(evt.currentTarget)
									.attr("aria-label", "Pygmentx disabled")
								.find(".label")
									.fadeTo(0, 0.5);
							} else {
								container.html(container.data("pygmentx-new"));
								container.data("pygmentx-current", "pygmentx-new");
								new JQuery(evt.currentTarget)
									.attr("aria-label", "Pygmentx enabled")
								.find(".label")
									.fadeTo(0, 1);
							}
							evt.preventDefault();
						})
						.appendTo(new JQuery(blobDiv).siblings(".meta").find(".button-group"));
				}
			);
	}

	static function processFileBoxDiv(fileBoxDiv:DivElement):Void {
		if (new JQuery(fileBoxDiv).find(".file-language").text().toLowerCase() != "haxe") {
			return;
		}

		var url = cast (new JQuery(".raw-url")[0], AnchorElement).href;
		// trace(url);
		var container = new JQuery(fileBoxDiv).find(".highlight .line-pre").parent();
		container
			.data("pygmentx-original", container.html())
			.load('http://pygmentx.onthewings.net/?url=${url} .highlight pre',
				function(responseText, textStatus, XMLHttpRequest){
					if (textStatus != "success") {
						trace(textStatus);
						trace(responseText);
						return;
					}
					container
						.data("pygmentx-new", container.html())
						.data("pygmentx-current", "pygmentx-new");
					
					new JQuery("<li class='tooltipped tooltipped-s' aria-label='Pygmentx enabled'><a href='#' class='file-actions-button'>Pygmentx</a></li>")
						.click(function(evt:Event){
							if (container.data("pygmentx-current") == "pygmentx-new") {
								container.html(container.data("pygmentx-original"));
								container.data("pygmentx-current", "pygmentx-original");
								new JQuery(evt.currentTarget)
									.attr("aria-label", "Pygmentx disabled")
								.find("a")
									.fadeTo(0, 0.5);
							} else {
								container.html(container.data("pygmentx-new"));
								container.data("pygmentx-current", "pygmentx-new");
								new JQuery(evt.currentTarget)
									.attr("aria-label", "Pygmentx enabled")
								.find("a")
									.fadeTo(0, 1);
							}
							evt.preventDefault();
						})
						.appendTo(new JQuery(fileBoxDiv).find(".button-group"));
				}
			);
	}
	
	static function main():Void {
		switch (Browser.location.hostname) {
			case "github.com":
				var blobDivSelector = ".blob-wrapper.type-haxe";
				var j = new JQuery(blobDivSelector);
				if (j.length > 0) {
					processGithubBlobDiv(cast j[0]);
				}
				var observer = new MutationSummary({
					callback: function(summaries:Array<Summary>){
						switch (summaries[0]) {
							case { added:[blobDiv] }:
								processGithubBlobDiv(cast blobDiv);
							case _: //pass
						}
					},
					queries: [{ element: [blobDivSelector] }]
				});
			case "gist.github.com":
				var fileBoxDivSelector = ".file-box";
				for (fileBoxDiv in new JQuery(fileBoxDivSelector)) {
					processFileBoxDiv(cast fileBoxDiv);
				}
				var observer = new MutationSummary({
					callback: function(summaries:Array<Summary>){
						for (fileBoxDiv in summaries[0].added) {
							processFileBoxDiv(cast fileBoxDiv);
						}
					},
					queries: [{ element: [fileBoxDivSelector] }]
				});
		}
	}
}