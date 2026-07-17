local Translations = {
    target = {
        search = 'Search Dumpster',
        break_mailbox = 'Break Into Mailbox'
    },
    progress = {
        searching = 'Searching...',
        breaking_mailbox = 'Breaking into mailbox...'
    },
    notify = {
        success = 'You found something!',
        failed = 'You could not find anything useful',
        dumpster_cooldown = 'This dumpster is still locked for %{seconds} seconds.',
        mailbox_cooldown = 'This mailbox is still locked for %{seconds} seconds.',
        no_lockpick = 'You need a lockpick to break into a mailbox.',
        mailbox_lockpick_broke = 'Your lockpick broke while struggling with the mailbox. You still managed to get it open though!'
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
