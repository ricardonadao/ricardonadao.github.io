(function ($) {
  var $comments = $('.js-comments');

  $('.js-form').submit(function () {
    var form = this;

    $(form).addClass('form--loading');

    $.ajax({
      type: $(this).attr('method'),
      url: $(this).attr('action'),
      data: $(this).serialize(),
      contentType: 'application/x-www-form-urlencoded',
      success: function (data) {
        showModal('Comment submitted', 'Thanks for your comment.');
        $(form).removeClass('form--loading');
      },
      error: function (err) {
        console.log(err);
        showModal('Error', 'Ooops somethign gone wrong with your comment, please feel free <a href="/about">contact<a> me');
        $(form).removeClass('form--loading');
      }
    });

    return false;
  });

  $('.js-close-modal').click(function () {
    $('body').removeClass('show-modal');
  });

  function showModal(title, message) {
    $('.js-modal-title').text(title);
    $('.js-modal-text').html(message);

    $('body').addClass('show-modal');
  }
})(jQuery);
