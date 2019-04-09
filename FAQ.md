# Frequently Asked Questions

## Start-up

### Q. `Error code: 0x223` is raised

You are most likely trying to start up the airplane in mid-air, for example on a final approach to a runway. This is [not possible with this aircraft](https://github.com/it0uchpods/IDG-A32X/issues/84#issuecomment-475035478).

The simulation is so complex that there is no support for starting it in mid-air. Therefore, please make sure that you start it on the ground, powering it up appropriately.

In case that you want to practice landing, it might be better to fly to your destination and by doing it using "touch-down" and "going around" (like real pilots do so, too).


## Reporting Issues / Debugging

### Q. Where should I report issues?

Please use our [issues page](https://github.com/it0uchpods/IDG-A32X/issues/new) to report bugs. Try to fill out the template there to the best of your knowledge.

### Q. I encountered a strange behavior while flying. Should I report a bug?

Yes, please do so! If we do not know about the bugs, there is no-one to fix them. 

### Q. I have a flight recording which shows the problem. Could you please have a look?

I does not make sense sending in flight recordings, as they do not contain enough information. That is why they are more or less useless for us.

Properly enabling the recording is also not what is reasonable: The recording would be quite CPU and memory intensive and certainly would have a negative impact on your flight experience.

Instead, for documenting issues, please perform the steps mentioned in the next question:

### Q. I want to document an issue. What is the right approach doing so?

Besides describing it with words, you may do two things, which helps us reproducing your issue locally such that it can be debugged:

1. Hit the screenshot buttons (hotkey `F3` by default) often and send them all in! Five screenshots with redundant data isn't a problem to sort out, but one screenshot missing out which would have contained vital information may prevent understanding the problem properly.

2. If able you may also dump the property tree (see menu "Debug"). That is also a very helpful source of information. 



## Do's and Don'ts

### Q. The current version has a bug, but I still want to keep flying. Can I downgrade?

First of all, did you ensure that the bug is reported on our [issues page](https://github.com/it0uchpods/IDG-A32X/issues/new)? If no, please do so (see also questions above on how to report them)!

Besides that, **never** downgrade your aircraft without resetting/deleting your `IDG-A32X-config.xml` file as well. You may find it in `$FGHOME/Export`.

### Q. I like increasing the simulation speed on long flights. However, I encounter issues with it once in a while. What's up?

Increasing the simulation speed is quite tricky for the simulator. Depending on hardware capabilities it can be very stressful and the algorithms behind the scenes can be challenged quite heavily. If the simulation is running faster than the corresponding algorithms can be computed, many funny (or even [ugly things](https://github.com/it0uchpods/IDG-A32X/issues/86#issuecomment-478328407)) may happen. So, be careful with that.

In general, one could say:

* Don't increase the simulation speed above 4x. A simulation speed of 8x is already quite heavy load for everything.
* Check your frame rate (you can enable showing it using the "View" menu, option "View Options", toggle "Show frame rate" there) when increasing the simulation speed. As a rule of thumb, if the frame rate stays constantly above 10fps, you are fine. Keep in mind that already one little phase (and not just the average) where the frame rate drops significantly, you are in danger facing issues.

