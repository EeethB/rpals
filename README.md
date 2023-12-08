![](www/rpals_logo.png)

# Stories are here for RStudio! :tada:

Inspired by Ben Awad's [VS Code Stories](https://github.com/ide-stories/vscode-stories) (And because people sharing code makes me happy :blush:), Rpals seeks to be an ultra-low-barrier-to-entry space for people to share their code with the R :earth_africa:

If you like Rpals and would like to support its development, you can

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/EeethB)

## Installation

I haven't even made this a package yet, so you can play around with Rpals by downloading or cloning this repository and running app2.R with RStudio. It is designed to be run from RStudio and viewed in the Viewer pane. It may break if run in other ways :shrug:

## Current state

Rpals currently has a very rough, mostly functional UI. The bulk of the UI layout is there, but it needs a couple more features & a bunch of styling. I want it to have some :sparkles: flair :sparkles:

## MVP

I think the only thing left to reach a minimal UI is a screen to create a profile, including choosing a display name and a profile picture

Minimal backend might just be dropping CSVs into an S3 bucket for now. My biggest concern here will be auth. Can I create an "rpals" user in AWS who only has read and write access, but not drop access? Since this is going to be distributed as an add-in, not a hosted app, anyone who downloads it will be able to see the S3/DB interaction code and could theoretically use it to mess with my storage system, I think :unamused: So that seems not great

Lately I've been thinking about this system, which would be more secure, but it has a much longer runway, since I don't actually know plumber yet.

1. Store the log-in creds data as a pin in a private GitHub repo for now (Could also use S3 or something else. Location doesn't matter much, as long as it's private)
1. Build an API with plumber that handles auth internally. This would have to be hosted somewhere. Can shinyapps.io host plumber APIs? My home Shiny Server setup is probably not reliable enough, since a kid could just go unplug it
1. Then the actual app that people download doesn't have data access, it just hits the plumber API with uname/pwd, and the API returns a boolean to say if they authenticated or not
1. Eventually all the data would hide behind the API so that some rando can't just drop all the tables. But initially at least people's passwords would be secure.

I think it could work!

## Future state

Future state is the biggest mess of the whole project! :laughing: I have all kinds of ideas with vastly different scopes, including, but not limited to:

1.  Curated pals list rather than feed of all users
2.  Text and video chatting? I want this to connect people!
3.  Plush toys! (And other merch) Some kind of "hugging Rs" where you keep one and send one to a pal
4.  Styling: I want the whole app to channel the energy of the logo - Soft, round, bright, and happy! But I currently don't know nearly enough CSS to pull this off
