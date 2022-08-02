# Stories are here for RStudio! :tada:

Inspired by Ben Awad's [VS Code Stories](https://github.com/ide-stories/vscode-stories) (And because people sharing code makes me happy :blush:), {rpals} seeks to be an ultra-low-barrier-to-entry space for people to share their code with the R :earth_africa:

If you like {rpals} and would like to support its development, you can

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/EeethB)

## Installation

I haven't even made this a package yet, so you can play around with {rpals} by downloading or cloning this repository and running app.R with RStudio. It is designed to be run from RStudio and viewed in the Viewer pane. It may break if run in other ways :shrug:

## Current state

{rpals} currently has a very rough, mostly functional UI. The bulk of the UI layout is there, but it needs some re-arranging and a bunch of styling. I want it to have some :sparkles: flair :sparkles:

## MVP

I think the only thing left to reach a minimal UI is adding a way to actually share your code. Right now you can only read in code from the shared code table I made up. I think at least a "share from clipboard" and a "share from current file" would be good

Minimal backend might just be dropping CSVs into an S3 bucket for now. My biggest concern here will be auth. Can I create an "rpals" user in AWS who only has read and write access, but not drop access? Since this is going to be distributed as an add-in, not a hosted app, anyone who downloads it will be able to see the S3/DB interaction code and could theoretically use it to mess with my storage system, I think :unamused: So that seems not great

## Future state

Future state is the biggest mess of the whole project! :laughing: I have all kinds of ideas with vastly different scopes, including, but not limited to:

1.  Curated pals list rather than feed of all users
2.  Text and video chatting? I want this to connect people!
3.  Plush toys! (And other merch) Some kind of "hugging Rs" where you keep one and send one to a pal
4.  Styling: I want the whole app to channel the energy of the logo - Soft, round, bright, and happy! But I currently don't know nearly enough CSS to pull this off
