/* =========================================================
 * bootstrap-modal.js v1.3.0
 * http://twitter.github.com/bootstrap/javascript.html#modal
 * =========================================================
 * Copyright 2011 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================= */

var j$ = jQuery.noConflict();
!function( j$ ){

 /* CSS TRANSITION SUPPORT (https://gist.github.com/373874)
  * ======================================================= */

  var transitionEnd

  j$(document).ready(function () {

    j$.support.transition = (function () {
      var thisBody = document.body || document.documentElement
        , thisStyle = thisBody.style
        , support = thisStyle.transition !== undefined || thisStyle.WebkitTransition !== undefined || thisStyle.MozTransition !== undefined || thisStyle.MsTransition !== undefined || thisStyle.OTransition !== undefined
      return support
    })()

    // set CSS transition event type
    if ( j$.support.transition ) {
      transitionEnd = "TransitionEnd"
      if ( j$.browser.webkit ) {
      	transitionEnd = "webkitTransitionEnd"
      } else if ( j$.browser.mozilla ) {
      	transitionEnd = "transitionend"
      } else if ( j$.browser.opera ) {
      	transitionEnd = "oTransitionEnd"
      }
    }

  })


 /* MODAL PUBLIC CLASS DEFINITION
  * ============================= */

  var Modal = function ( content, options ) {
    this.settings = j$.extend({}, j$.fn.modal.defaults, options)
    this.j$element = j$(content)
      .delegate('.close', 'click.modal', j$.proxy(this.hide, this))

    if ( this.settings.show ) {
      this.show()
    }

    return this
  }

  Modal.prototype = {

      toggle: function () {
        return this[!this.isShown ? 'show' : 'hide']()
      }

    , show: function () {
        var that = this
        this.isShown = true
        this.j$element.trigger('show')

        escape.call(this)
        backdrop.call(this, function () {
          var transition = j$.support.transition && that.j$element.hasClass('fade')

          that.j$element
            .appendTo(document.body)
            .show()

          if (transition) {
            that.j$element[0].offsetWidth // force reflow
          }

          that.j$element
            .addClass('in')

          transition ?
            that.j$element.one(transitionEnd, function () { that.j$element.trigger('shown') }) :
            that.j$element.trigger('shown')

        })

        return this
      }

    , hide: function (e) {
        e && e.preventDefault()

        if ( !this.isShown ) {
          return this
        }

        var that = this
        this.isShown = false

        escape.call(this)

        this.j$element
          .trigger('hide')
          .removeClass('in')

        function removeElement () {
          that.j$element
            .hide()
            .trigger('hidden')

          backdrop.call(that)
        }

        j$.support.transition && this.j$element.hasClass('fade') ?
          this.j$element.one(transitionEnd, removeElement) :
          removeElement()

        return this
      }

  }


 /* MODAL PRIVATE METHODS
  * ===================== */

  function backdrop ( callback ) {
    var that = this
      , animate = this.j$element.hasClass('fade') ? 'fade' : ''
    if ( this.isShown && this.settings.backdrop ) {
      var doAnimate = j$.support.transition && animate

      this.j$backdrop = j$('<div class="modal-backdrop ' + animate + '" />')
        .appendTo(document.body)

      if ( this.settings.backdrop != 'static' ) {
        this.j$backdrop.click(j$.proxy(this.hide, this))
      }

      if ( doAnimate ) {
        this.j$backdrop[0].offsetWidth // force reflow
      }

      this.j$backdrop.addClass('in')

      doAnimate ?
        this.j$backdrop.one(transitionEnd, callback) :
        callback()

    } else if ( !this.isShown && this.j$backdrop ) {
      this.j$backdrop.removeClass('in')

      function removeElement() {
        that.j$backdrop.remove()
        that.j$backdrop = null
      }

      j$.support.transition && this.j$element.hasClass('fade')?
        this.j$backdrop.one(transitionEnd, removeElement) :
        removeElement()
    } else if ( callback ) {
       callback()
    }
  }

  function escape() {
    var that = this
    if ( this.isShown && this.settings.keyboard ) {
      j$(document).bind('keyup.modal', function ( e ) {
        if ( e.which == 27 ) {
          that.hide()
        }
      })
    } else if ( !this.isShown ) {
      j$(document).unbind('keyup.modal')
    }
  }


 /* MODAL PLUGIN DEFINITION
  * ======================= */

  j$.fn.modal = function ( options ) {
    var modal = this.data('modal')

    if (!modal) {

      if (typeof options == 'string') {
        options = {
          show: /show|toggle/.test(options)
        }
      }

      return this.each(function () {
        j$(this).data('modal', new Modal(this, options))
      })
    }

    if ( options === true ) {
      return modal
    }

    if ( typeof options == 'string' ) {
      modal[options]()
    } else if ( modal ) {
      modal.toggle()
    }

    return this
  }

  j$.fn.modal.Modal = Modal

  j$.fn.modal.defaults = {
    backdrop: false
  , keyboard: false
  , show: false
  }


 /* MODAL DATA- IMPLEMENTATION
  * ========================== */

  j$(document).ready(function () {
    j$('body').delegate('[data-controls-modal]', 'click', function (e) {
      e.preventDefault()
      var j$this = j$(this).data('show', true)
      j$('#' + j$this.attr('data-controls-modal')).modal( j$this.data() )
    })
  })

}( window.jQuery || window.ender );