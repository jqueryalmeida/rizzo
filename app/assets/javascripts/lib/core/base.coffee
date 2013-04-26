define( ['jquery','lib/core/ad_manager_old','lib/utils/asset_fetch', 'lib/core/authenticator','lib/core/shopping_cart', 'lib/core/msg', 'lib/utils/local_store', 'lib/managers/select_group_manager'], ($, AdManager, AssetFetch, Authenticator, ShoppingCart, Msg, LocalStore, SelectGroup) ->

  class Base

    constructor: (args={})->
      @authenticateUser()
      @showUserBasket()
      @initAds() if !args.secure
      @showCookieComplianceMsg()
      @initialiseFooterSelects()
      @addNavTracking()

    adConfig: ->
      adZone : window.lp.ads.adZone or window.adZone or 'home'
      adKeywords : window.lp.ads.adKeywords or window.adKeywords or ' '
      tile : lp.ads.tile or 1
      ord : lp.ads.ord or window.ord or Math.random()*10000000000000000
      segQS : lp.ads.segQS or window.segQS or ' '
      mtfIFPath : (lp.ads.mtfIFPath or '/')
      unit: [728,90]
      # sizes is all that's needed for the new implementation. The above can all be ditched when switching to the new manager.
      sizes:
        adSenseCard: [155,256]
        trafficDriver: [155,256]
        sponsorTile: [276,32]
        oneByOne: [1,1]
        leaderboard: [[970,66], [728,90]]
        mpu: [[300,250], [300, 600]]
      
    authenticateUser: ->
      @auth = new Authenticator()
      AssetFetch.get "https://secure.lonelyplanet.com/sign-in/status", () =>
        @auth.update()

    initAds: ->
      AdManager.init(@adConfig(), 'js-ad-leaderboard') # Remove the second param when dropping the old ad manager

    showUserBasket: ->
      shopCart = new ShoppingCart()

    initialiseFooterSelects: ->
      countrySelect = new SelectGroup '.js-select-country'
      languageSelect = new SelectGroup '.js-select-language', ->
        $('#js-language').submit()

    showCookieComplianceMsg: ->
      if LocalStore.get('cookie-compliance') is undefined or LocalStore.get('cookie-compliance') is null
        args = 
          content: "<p><strong>Hi there. We use cookies to improve your experience on our website. </strong><strong><a href='/legal/cookies'>Find out more about how we use cookies.</a></strong></p><p>You can update your settings by clicking the <strong><a href='/legal/cookies'>Cookie Policy</a></strong> link which can be found anytime at the bottom of the page.</p>"
          style: "row--cookie-compliance js-cookie-compliance"
          delegate: 
            onRemove : -> 
              $('div.js-cookie-compliance').removeClass('row--cookie-compliance--open')
              $('div.js-cookie-compliance').addClass('row--cookie-compliance--close')
            onAdd : -> 
              window.setTimeout( ( => $('div.js-cookie-compliance').addClass('row--cookie-compliance--open')), 1)
        msg = new Msg(args)
        LocalStore.set('cookie-compliance', true)

    addNavTracking: ->
      $('#js-primary-nav').on 'click', '.js-nav-item', ->
        window.s.linkstacker($(this).text())

      $('#js-primary-nav').on 'click', '.js-nav-cart', ->
        window.s.linkstacker("shopping-cart")

      $('#js-primary-nav').on 'submit', '.js-nav-search', ->
        window.s.linkstacker("search")

      $('#js-secondary-nav').on 'click', '.js-nav-item', ->
        window.s.linkstacker($(this).text() + "-sub")

      $('#js-breadcrumbs').on 'click', '.js-nav-item', ->
        window.s.linkstacker("breadcrumbs")

      $('#js-footer-nav').on 'click', '.js-nav-item', ->
        window.s.linkstacker("footer")

)
