** How to translate Ultrastar WorldParty to your language **

First of all, thanks for your interest helping us to approach the game to more people.

You should clone the project to make the changes.

Check if your language is under this folder.

If your language is already created, you should edit that file, if not, copy the English file and rename it to your language.


--------------------
Translating texts:
--------------------

- First, check if there are lines with "TODO:" prefix at the begining.

- You have to translate everything to the right of the "=" sign.

- Once done, delete the "TODO:" prefix. DO NOT remove it if you haven't translated it

- Keep in mind, there are some weird signs in the translation, we use it to introduce additional information in the game, DO NOT remove it, adjust it with the rest of the sentence translated. Here you have more info:

-----------------------
3. Wildcards:
-----------------------

STAT_OVERVIEW_INTRO:
  Format:
    %0:d Ultrastar Version
    %1:d Day of Reset (A1)
    %2:d Month of Reset (A2)
    %3:d Year of Reset (A3)

STAT_OVERVIEW_SONG:
  Format:
    %0:d Count Songs (A1)
    %1:d Count of Sung Songs (A2)
    %2:d Count of UnSung Songs
    %3:d Count of Songs with Video (A3)
    %4:s Name of the most popular Song

STAT_OVERVIEW_PLAYER:
  Format:
    %0:d Count Players (A1)
    %1:s Best Player (Result)
    %2:d Best Players Score
    %3:s Best Score Player (Result2)
    %4:d Best Score

STAT_FORMAT_SCORES:
  Format:
    %0:s Singer
    %1:d Score
    %2:s Difficulty
    %3:s Song Artist   
    %4:s Song Title

STAT_FORMAT_SINGERS:
  Format:
    %0:s Singer
    %1:d Average Score


STAT_FORMAT_SONGS:
  Format:
    %0:s Artist
    %1:s Title
    %2:d Times Sung

STAT_FORMAT_BANDS:
  Format:
    %0:s Artist Name
    %1:d Times Sung

Some further explanations about the wildcards:
%x:[.y]z

Where X is the number of the wildcard,
Y is optional, it is the number of digits for deciaml numbers (Z=d). So, if y is 2 there and the number is only 0 to 9 there will be a zero added in front of the number.
z can be d for numbers and s for texts

For the date thing in STAT_OVERVIEW_INTRO you may use %1:.2d for the day and %2:.2d for the month.


Once you're done, create a pull request with your changes, or you can upload it to our forum https:/ultrastar-es.org/foro

If you have any doubt in any translation, you can ask in our forum, we'll be pleased to help you.

we'll add you to the credits in github, once merged ;)
