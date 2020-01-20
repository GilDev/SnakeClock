# Snake Clock

This is an original and fun clock face where a snake lives its day along yours.
It’s my first ever Flutter app!


## How does it work?

The snake’s head represent the current time. Each hour is a line, and minutes are the head’s horizontal position.
Use the left or right indicators to know the hour and the top or bottom indicator the minutes (they are updated according to the snake’s direction, because it goes right on even hours and left on odd hours).
It’s actually quite precise, with some training you can read the hour down to a minute or two (it’s not the head’s end but the head’s center that indicates the exact minute).

The tongue goes in and out each second, and the eyes blink every ten seconds.

The snake’s color changes with the current season: blue for winter, green for spring, yellow for summer and orange for fall.

The snake eats an apple at 9:30, 13:30 and 19:30, each of a different color because he doesn’t like routine.


## What could be improved

* Right and bottom indications could be removed so that the snake takes up more space, but it would become uncentered.
* Maybe instead of showing all hour indicators, show the current one (still aligned with the snake).
* Snake’s color could be a gradient showing the today’s outside temperature: it would be blue at ~0°C (or min day temp) and red at ~30°C (or max day temp) with a linear gradient inbetween. This would be painted on each segment (about 1 per minute) of the snake to get a view of the day’s temperature. In the end, the snake would start blue and go red as the sun rise then blue again when it’s night time.
* The snake could turn around in a circular arc instead of right angles, and have a more linear travel when changing hour, though it would be more precise to read time. Otherwise, make a smooth transition from hour to hour (not sure on how to do that in a clean way using a canvas…)
* The snake could be decorated with little teardrops when it rains, clouds when it’s cloudy, snowflakes when it snows, stripes when there are thunderstorms…
* Maybe show an AM/PM indicator? Not sure if that’s useful, we never use 12h mode in our country (comparing the two, I don’t really see the point of 12h mode…).
* Make tongue go up and down instead of in and out?
* Code could probably be refactored to make it a lot cleaner, for example I don’t know where to make the snake positions calculations (which are right now duplicated in SnakePainter and IndicationsPainter, ugly…).
* Maybe the apples could be hand drawn in Flutter instead of printing an image, it would be easier to change the color and maybe more efficient too?