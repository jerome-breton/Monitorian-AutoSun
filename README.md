Monitorian AutoSun
==================

Monitorian AutoSun is a project aimed at improving the user experience of computer users by automatically adjusting the screen brightness based on the time of day.

Features
--------

- Uses the [Monitorian](//github.com/emoacht/Monitorian) project for screen brightness adjustment
- Uses the [sunrise-sunset.org API](//sunrise-sunset.org/) to retrieve sunrise and sunset times
- Use a simple Sinewave form to compute sunlight
- Allows customization of brightness thresholds per screen
- Pretty dumb and simple script, easy to maintain, easy to break

Prerequisites
-------------

Monitorian must be installed on the system and must respond to the `Monitarian` command.

This should be the case if you installed it via [Microsoft Store](//www.microsoft.com/store/apps/9nw33j738bl0).
<br><a href='//www.microsoft.com/store/apps/9nw33j738bl0?cid=storebadge&ocid=badge'><img src='https://developer.microsoft.com/store/badges/images/English_get-it-from-MS.png' alt='Monitorian' width='142px' height='52px'/></a>

Technologies Used
-----------------

- PowerShell for main script
- A bit of VBScript to wrap the launcher and prevent a window flash
- Windows Task Scheduler to periodicaly launch the script

Installation
------------

1. Clone the project repository to the directory of your choice:

    ```git clone https://github.com/jerome-breton/Monitorian-AutoSun.git```

2. Copy the `settings.json.dist` file to `settings.json` and edit it according to your needs.
3. Open PowerShell and launch `./script.ps1` to check that everything is running fine.
4. Open the Windows Task Scheduler and import the `Monitorian-AutoSun-Task.xml` file.
5. In the "Actions" tab, modify the path to locate the `run.vbs` file.
6. Save & Enjoy

settings.json details
---------------------

| Setting          | Description                                                   |
| ---------------- | ------------------------------------------------------------- |
| `lat`            | Latitude coordinate for the location                          |
| `lon`            | Longitude coordinate for the location                         |
| `sunrise_type`   | Type of sunrise calculation. Possible values: `absolute`, `civil`, `nautical`, or `astronomical`[^twilight] |
| `sunset_type`    | Type of sunset calculation. Possible values: `absolute`, `civil`, `nautical`, or `astronomical`[^twilight] |
| `screens`        | Array of screen configurations, each containing the following options: |
| <li>`id`</li>    | Identifier of the screen[^screen]                             |
| <li>`min`</li>   | Minimum brightness threshold for the screen (0-100)[^minmax]  |
| <li>`max`</li>   | Maximum brightness threshold for the screen (0-100)[^minmax]  |

[^twilight]: The different types of sunrise and sunset calculations represent different levels of daylight intensity based on the position of the sun below the horizon:

    - **Absolute**: The moment when the sun is exactly at the horizon.
    - **Civil**: The time at which there is enough light for most outdoor activities (sun is at 6° under the horizon).
    - **Nautical**: The time when the horizon is still visible at sea (sun is at 12° under the horizon).
    - **Astronomical**: The time when the sky is dark enough for astronomical observations (sun is at 18° under the horizon).

    More on this [here](https://www.timeanddate.com/astronomy/different-types-twilight.html).
    
[^screen]: To obtain screens ids, you can:

    1. Run Monitorian to get all screens and their current brightness: `Monitorian /get all`
    2. Monitorian will display information about the connected screens, including their IDs. Make a note of these IDs for each screen.
    > **Note:** The IDs may contain backslashes `\`, so make sure to double them (`\\`) in order to maintain valid JSON syntax in the `settings.json` file.

    You can also use `all` to set all screens at the same time.

    Screens brightness are updated in the same order than the `screens` array.

[^minmax]: Screens min/max

	**TL;DR: Use the same range you used in Monitorian, especially if you use the unison mode in Monitorian.**

	Monitorian will not allow the use of values outside its configured range for each screen. 
	Therefore, you can safely specify the range from 0 to 100 in the `settings.json` file.

	By the way, this script utilizes the specified range to achieve a more progressive approach.

	For instance, let's consider a scenario where Screen #1 has a range from 50 to 100, and Screen #2 has a range from 0 to 50.

	If you desire a global brightness of 50 and issue the command `Monitorian /set all 50`, it will set both screens to 50%. 
	However, this would result in Screen #1 being at its lowest brightness and Screen #2 being at its highest brightness.

	In this script, the specified range will adjust the brightness accordingly. In this scenario, Screen #1 will be set to 75% brightness, 
	and Screen #2 will be set to 25% brightness, matching the desired range more effectively. 
	This achieves the same result as the "unison" mode in Monitorian, although the CLI interface ignores it.
    

License
-------

Monitorian AutoSun is distributed under the MIT License. 
Please see the [LICENSE.md](LICENSE.md) file for more information about the license.

Contributions
-------------

Contributions to the project are welcome! If you'd like to contribute, just:

1. Fork this repo
2. Commit you code
3. Submit a pull request

Bug Reports and Feature Requests
--------------------------------

If you encounter any issues or have ideas for improvements, please [open an issue](//github.com/jerome-breton/Monitorian-AutoSun/issues) on the project's GitHub repository to let me know.

Improvement ideas
-----------------

- [ ] Add support for additional sun curve schemes.
- [ ] Allow the flexibility to change the path of Monitorian.
- [ ] Enhance the reliability of the settings by implementing value checks to ensure valid input.
- [ ] Improve logging functionality. Currently, the log file only retains the last call and is overwritten each time.