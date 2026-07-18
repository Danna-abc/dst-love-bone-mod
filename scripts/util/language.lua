function IsChineseLanguage()
    if GLOBAL.LanguageTranslator and GLOBAL.LanguageTranslator.defaultlang == "zh" then
        return true
    end
    return false
end
