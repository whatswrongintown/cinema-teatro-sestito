function is_youtubelink(url) {
    var p = /^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))((\w|-){11})(?:\S+)?$/;
    return (url.match(p)) ? RegExp.$1 : false;
}

function is_imagelink(url) {
    var p = /([a-z\-_0-9\/\:\.]*\.(jpg|jpeg|png|gif|webp))/i;
    return (url.match(p)) ? true : false;
}

function is_vimeolink(url, el) {
    var id = false;
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function() {
        if (xmlhttp.readyState == XMLHttpRequest.DONE) {
            if (xmlhttp.status == 200) {
                var response = JSON.parse(xmlhttp.responseText);
                id = response.video_id;
                el.classList.add('lightbox-vimeo');
                el.setAttribute('data-id', id);
                el.addEventListener("click", function(event) {
                    event.preventDefault();
                    openLightbox(this, 'vimeo');
                });
            }
        }
    };
    xmlhttp.open("GET", 'https://vimeo.com/api/oembed.json?url=' + url, true);
    xmlhttp.send();
}

document.addEventListener("DOMContentLoaded", function() {
    var lightbox = document.createElement("div");
    var originalOpener = null;
    var galleryLinks = [];
    var currentGalleryIndex = -1;
    var inertElements = [];
    var originalBodyOverflow = '';

    lightbox.setAttribute('id', "lightbox");
    lightbox.setAttribute('role', "dialog");
    lightbox.setAttribute('aria-modal', "true");
    lightbox.setAttribute('aria-label', "Visualizzatore di immagini e video");
    lightbox.setAttribute('aria-hidden', "true");
    lightbox.setAttribute('tabindex', "-1");
    document.body.appendChild(lightbox);

    function getDescription(element) {
        var image = element.querySelector('img');
        var href = element.getAttribute('href') || '';
        var filename = href.split('/').pop().split('.')[0];
        return (image && image.getAttribute('alt')) ||
            element.getAttribute('data-caption') ||
            element.getAttribute('title') ||
            filename ||
            'Elemento multimediale';
    }

    function getGalleryLinks(element) {
        var container = element.closest('ul, p');
        var links = container ?
            Array.prototype.slice.call(container.querySelectorAll("a[class*='lightbox-']")) :
            [];
        return links.length ? links : [element];
    }

    function rememberModalBackground() {
        originalBodyOverflow = document.body.style.overflow;
        document.body.style.overflow = 'hidden';
        inertElements = [];

        Array.prototype.forEach.call(document.body.children, function(element) {
            if (element === lightbox) return;
            inertElements.push({
                element: element,
                wasInert: element.hasAttribute('inert')
            });
            element.setAttribute('inert', '');
        });
    }

    function restoreModalBackground() {
        document.body.style.overflow = originalBodyOverflow;
        inertElements.forEach(function(item) {
            if (!item.wasInert) item.element.removeAttribute('inert');
        });
        inertElements = [];
    }

    function createControl(id, label, symbol) {
        var button = document.createElement('button');
        button.type = 'button';
        button.id = id;
        button.setAttribute('aria-label', label);
        button.textContent = symbol;
        return button;
    }

    function createMedia(element, type) {
        if (type === 'image') {
            var imageContainer = document.createElement('div');
            var image = document.createElement('img');
            imageContainer.className = 'img';
            imageContainer.style.backgroundImage = "url('" + element.getAttribute('href').replace(/'/g, "\\'") + "')";
            imageContainer.style.backgroundPosition = 'center center';
            imageContainer.style.backgroundSize = 'contain';
            imageContainer.style.backgroundRepeat = 'no-repeat';
            imageContainer.title = getDescription(element);
            image.src = element.getAttribute('href');
            image.alt = getDescription(element);
            imageContainer.appendChild(image);
            return imageContainer;
        }

        var videoContainer = document.createElement('div');
        var videoWrapper = document.createElement('div');
        var iframe = document.createElement('iframe');
        var videoId = element.getAttribute('data-id');
        videoContainer.className = 'videoWrapperContainer';
        videoWrapper.className = 'videoWrapper';
        iframe.src = type === 'vimeo' ?
            'https://player.vimeo.com/video/' + videoId + '/?autoplay=1&byline=0&title=0&portrait=0' :
            'https://www.youtube.com/embed/' + videoId + '?autoplay=1&showinfo=0&rel=0';
        iframe.title = getDescription(element);
        iframe.setAttribute('allowfullscreen', '');
        videoWrapper.appendChild(iframe);
        videoContainer.appendChild(videoWrapper);
        return videoContainer;
    }

    function renderLightbox(element, type, focusId) {
        var closeButton = createControl('close', 'Chiudi visualizzatore', '');
        var previousButton = createControl('prev', 'Elemento precedente', '\u2039');
        var nextButton = createControl('next', 'Elemento successivo', '\u203a');

        galleryLinks = getGalleryLinks(element);
        currentGalleryIndex = galleryLinks.indexOf(element);
        lightbox.classList.toggle('gallery', galleryLinks.length > 1);
        lightbox.innerHTML = '';
        lightbox.appendChild(closeButton);
        if (galleryLinks.length > 1) {
            lightbox.appendChild(nextButton);
            lightbox.appendChild(previousButton);
        }
        lightbox.appendChild(createMedia(element, type));

        galleryLinks.forEach(function(link) {
            link.classList.toggle('current', link === element);
        });

        var focusTarget = focusId && lightbox.querySelector('#' + focusId);
        (focusTarget || closeButton).focus();
    }

    function openLightbox(element, type) {
        var wasClosed = lightbox.getAttribute('aria-hidden') === 'true';
        if (wasClosed) {
            originalOpener = element;
            rememberModalBackground();
            lightbox.setAttribute('aria-hidden', 'false');
        }
        lightbox.style.display = 'block';
        renderLightbox(element, type, wasClosed ? 'close' : null);
    }

    window.openLightbox = openLightbox;

    function closeLightbox() {
        if (lightbox.getAttribute('aria-hidden') === 'true') return;

        var opener = originalOpener;
        lightbox.innerHTML = '';
        lightbox.classList.remove('gallery');
        lightbox.style.display = 'none';
        lightbox.setAttribute('aria-hidden', 'true');
        galleryLinks.forEach(function(link) {
            link.classList.remove('current');
        });
        galleryLinks = [];
        currentGalleryIndex = -1;
        restoreModalBackground();
        originalOpener = null;
        if (opener && document.contains(opener)) opener.focus();
    }

    function navigate(direction, focusId) {
        if (galleryLinks.length < 2 || currentGalleryIndex < 0) return;
        var index = (currentGalleryIndex + direction + galleryLinks.length) % galleryLinks.length;
        var link = galleryLinks[index];
        var type = link.classList.contains('lightbox-image') ? 'image' :
            (link.classList.contains('lightbox-vimeo') ? 'vimeo' : 'youtube');
        renderLightbox(link, type, focusId);
    }

    lightbox.addEventListener("click", function(event) {
        var control = event.target.closest('button');
        if (control && control.id === 'close') {
            closeLightbox();
        } else if (control && control.id === 'prev') {
            navigate(-1, 'prev');
        } else if (control && control.id === 'next') {
            navigate(1, 'next');
        } else if (event.target === lightbox) {
            closeLightbox();
        }
    });

    lightbox.addEventListener("keydown", function(event) {
        if (event.key === 'Escape') {
            event.preventDefault();
            closeLightbox();
            return;
        }
        if (event.key === 'ArrowLeft') {
            event.preventDefault();
            navigate(-1, 'prev');
            return;
        }
        if (event.key === 'ArrowRight') {
            event.preventDefault();
            navigate(1, 'next');
            return;
        }
        if (event.key !== 'Tab') return;

        var focusable = Array.prototype.filter.call(
            lightbox.querySelectorAll('button:not([disabled]), iframe, [href], [tabindex]:not([tabindex="-1"])'),
            function(element) {
                return !element.hasAttribute('hidden');
            }
        );
        if (!focusable.length) {
            event.preventDefault();
            lightbox.focus();
            return;
        }

        var first = focusable[0];
        var last = focusable[focusable.length - 1];
        if (event.shiftKey && document.activeElement === first) {
            event.preventDefault();
            last.focus();
        } else if (!event.shiftKey && document.activeElement === last) {
            event.preventDefault();
            first.focus();
        }
    });

    var elements = document.querySelectorAll('a:not(.no-lightbox)');
    elements.forEach(function(element) {
        var url = element.getAttribute('href');
        if (!url) return;

        if (url.indexOf('vimeo.com') !== -1) {
            is_vimeolink(url, element);
        }
        if (is_youtubelink(url)) {
            element.classList.add('lightbox-youtube');
            element.setAttribute('data-id', is_youtubelink(url));
            element.addEventListener("click", function(event) {
                event.preventDefault();
                openLightbox(this, 'youtube');
            });
        }
        if (is_imagelink(url) || element.classList.contains('lightbox-image')) {
            element.classList.add('lightbox-image');
            if (!element.hasAttribute('title')) {
                element.setAttribute('title', url.split('/').pop().split('.')[0]);
            }
            element.addEventListener("click", function(event) {
                event.preventDefault();
                openLightbox(this, 'image');
            });
        }
    });
});
