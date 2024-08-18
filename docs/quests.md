# these are messy docs, check the src if something is missing

global object 'quests' stores all quests

a quest is
# QuestDef or sumn
{
    type = "quest"/"text"/"secret",
    title = "Quest Name",
    text = "Instructions or text here.",
    requires = {"Other Quests Name"}
}
text is needed even if type isnt text

requires will hide the text but now the title, until the list of required quests is completed
secret quests will not appear at all until theyre completed

if you omit requires / provide an empty list the quest will be available from the beginning

# some methods

unlock_achievement(player_name, quest_name)
Marks the quest as completed.

revoke_achievement(player_name, quest_name)
Removes the completion from the quest, should generally not be used.

is_achievement_unlocked(player_name, quest_name)
Checks if the quest has been completed.

is_quest_available(player_name, quest_name)
Checks if the required quests for the specified quest have been completed.

