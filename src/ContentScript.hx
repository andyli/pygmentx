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
		var url = cast (new JQuery(blobDiv).parent(".file").find("#raw-url, .raw-url")[0], AnchorElement).href;
		// trace(url);
		var container = new JQuery(blobDiv).find(".highlight pre").parent();
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
					
					var buttonGroup = new JQuery(blobDiv).siblings(".meta").find(".button-group");
					var toggleBtn = new JQuery("<a href='#' class='minibutton tooltipped tooltipped-s' aria-label='Pygmentx enabled'><span class='label'>Pygmentx</span></a>")
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
						.appendTo(buttonGroup);
					if (buttonGroup.find("a.button").length > 0) {
						toggleBtn.addClass("button");
					}
				}
			);
	}

	
	static function main():Void {
		switch (Browser.location.hostname) {
			case "github.com", "gist.github.com":
				var blobDivSelector = ".blob-wrapper.type-haxe";
				for (div in new JQuery(blobDivSelector)) {
					processGithubBlobDiv(cast div);
				}
				var observer = new MutationSummary({
					callback: function(summaries:Array<Summary>){
						switch (summaries[0]) {
							case { added:blobDivs }:
								for (div in blobDivs)
									processGithubBlobDiv(cast div);
							case _: //pass
						}
					},
					queries: [{ element: [blobDivSelector] }]
				});
		}
	}
}