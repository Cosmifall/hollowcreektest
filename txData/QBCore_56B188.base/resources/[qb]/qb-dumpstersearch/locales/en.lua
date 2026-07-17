local Translations = {
    target = {
        search = 'Search Dumpster'
    },
    progress = {
        searching = 'Searching...'
    },
    notify = {
        success = 'You found something!',
        failed = 'You could not find anything useful'
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
