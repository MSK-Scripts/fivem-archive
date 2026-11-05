var showMemberList
var voiceSystem
var speaker

window.addEventListener('message', function(event) {
  const data = event.data
  
  if (data.action == "openUI") {
    showMemberList = data.showMemberList
    voiceSystem = data.voiceSystem
    speaker = data.showSpeaker
    setLanguage(data.locales)
    handleSlider(data.volume)

    $(".content").css("filter", "none")
    $(".popup").hide()
    $("#member-list-checkbox-container").hide()
    $("#ui").fadeIn("fast")

    if (data.isInChannel) {
      $(".frequence-input").val(data.isInChannel)
      showJoinPage()
    }
  } else if (data.action == "refreshVolume") {
    handleSlider(data.volume)
  } else if (data.action == "closeUI") {
    closeUI()
  }
})

$(document).ready(function() {
  $(".enter-channel-button").click(function() {
    $.post(`https://${GetParentResourceName()}/enter-channel`, JSON.stringify({frequence: $(".frequence-input").val()}), function(resp) {
      if (resp == 'input') {
        showPopup()
      } else if (resp == 'OK') {
        showJoinPage()
      }
    })
  })
  $(".leave-channel-button").click(function() {
    $.post(`https://${GetParentResourceName()}/leave-channel`, JSON.stringify({frequence: $(".frequence-input").val()}))

    $(".frequence-input").val("")
    $("#joined-page").fadeOut("fast")
    $(".member-list").fadeOut("fast")
    $("#speaker-checkbox-container").hide()
    $("#member-list-checkbox-container").hide()
    document.getElementById("member-list-checkbox").checked = false;
    $(".container").removeClass("container-joined-page-active")
    $(".container").removeClass("container-member-list-active")
    $("#main-page").fadeIn("fast")
  })
  $("#refresh-button").click(function() {
    $.post(`https://${GetParentResourceName()}/refresh-member`, JSON.stringify({frequence: $(".frequence-input").val()}), function(resp) {
      if (resp) {
        $("#member-list").empty()

        resp.forEach(function(v, k) {
          $("#member-list").append(`
            <div class="member-list-item"><span class="white-mask">${v.name}</span></div>
          `)
        })
      }
    })
  })
  $(".popup-button").click(function() {
    $.post(`https://${GetParentResourceName()}/popup-action`, JSON.stringify({frequence: $(".frequence-input").val(), password: $(".popup-input").val()}), function(resp) {
      if (resp == 'OK') {
        closePopup()
        showJoinPage()
      }
    })
  })
  $("#member-list-checkbox").click(function() {
    let isChecked = document.getElementById("member-list-checkbox").checked
    $(".container").removeClass("container-joined-page-active")
    $(".container").removeClass("container-member-list-active")

    if (isChecked) {
      $(".container").addClass("container-member-list-active")
      $("#member-list").empty()

      $.post(`https://${GetParentResourceName()}/refresh-member`, JSON.stringify({frequence: $(".frequence-input").val()}), function(resp) {
        if (resp) {
          $("#member-list").empty()

          resp.forEach(function(v, k) {
            $("#member-list").append(`
              <div class="member-list-item"><span class="white-mask">${v.name}</span></div>
            `)
          })
        }
      })

      $(".member-list").fadeIn("fast")
    } else {
      $(".member-list").fadeOut("fast")
      $(".container").addClass("container-joined-page-active")
    }
  })
  $("#streamer-mode-checkbox").click(function() {
    let isChecked = $(this).attr("checked")

    if (isChecked) {
      $(this).removeAttr("checked")
      $(".frequence-input").attr("type", "number")
      $("#current-frequence").removeClass("blurred")
      $(".popup-input").attr("type", "number")
    } else {
      $(this).attr("checked", true)
      $(".frequence-input").attr("type", "password")
      $("#current-frequence").addClass("blurred")
      $(".popup-input").attr("type", "password")
    }
  })
  $("#speaker-checkbox").click(function() {
    let isChecked = $(this).attr("checked")

    if (isChecked) {
      isChecked = false
      $(this).removeAttr("checked")
    } else {
      isChecked = true
      $(this).attr("checked", true)
    }

    $.post(`https://${GetParentResourceName()}/radio-speaker`, JSON.stringify({activate: isChecked}))
  })
})

document.onkeyup = function (event) {
  if (event.key == "Escape") {
    closeUI()
  }
}

function showJoinPage() {
  $("#joined-page").fadeIn("fast")
  $("#main-page").fadeOut("fast")

  if (showMemberList) {
    $("#member-list-checkbox-container").show()
  }

  $(".container").removeClass("container-joined-page-active")
  $(".container").removeClass("container-member-list-active")
  $(".container").addClass("container-joined-page-active")
  $("#current-frequence").text($(".frequence-input").val())

  if (speaker & voiceSystem == 'saltychat') {
    $("#speaker-checkbox-container").show()
  }

  let isChecked = document.getElementById("member-list-checkbox").checked
  if (isChecked) {
    $(".container").addClass("container-member-list-active")
  } else {
    $(".container").addClass("container-joined-page-active")
  }
}

function showPopup() {
  $(".content").css("filter", "blur(0.6vh")
  $(".popup").fadeIn("fast")
}

function closePopup() {
  $(".content").css("filter", "none")
  $(".popup").fadeOut("fast")
  $(".popup-input").val("")
}

function handleSlider(volume) {
  const slider = document.getElementById("volume-slider")

  if (volume) {
    percent = volume
    slider.value = volume
  } else {
    percent = Math.floor((slider.value / slider.max) * 100)
  }

  slider.style.background = `linear-gradient(to right, var(--slider-inner) ${percent}%, var(--slider-outer) ${percent}%)`
  $("#volume-percent").text(percent + "%")

  $.post(`https://${GetParentResourceName()}/change-volume`, JSON.stringify({volume: percent}))
}
// handleSlider(100)

function closeUI() {
  closePopup()
  $("#ui").fadeOut("fast")
  $.post(`https://${GetParentResourceName()}/closeUI`)
}

function setLanguage(locales) {
  $("#top-banner-title").text(locales.radio_header)
  $("#main-page-info-title").text(locales.insert_frequenz)
  $("#join-page-info-title").text(locales.current_frequenz)
  $(".frequence-input").attr("placeholder", locales.insert_frequenz_placeholder)
  $("#enter-channel-button-text").text(locales.confirm)
  $("#leave-channel-button-text").text(locales.leave)
  $("#volume-slider-title").text(locales.volume)
  $("#streamer-mode-checkbox-textt").text(locales.streamer_mode)
  $("#speaker-checkbox-text").text(locales.speaker)
  $("#member-list-checkbox-text").text(locales.show_members)
  $("#popup-title").text(locales.create_password)
  $(".popup-info-title").text(locales.create_password_subtitle)
  $(".popup-input").attr("placeholder", locales.create_password_placeholder)
  $("#popup-button-text").text(locales.confirm)
}