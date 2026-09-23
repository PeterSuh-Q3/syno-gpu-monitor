/*
 * Shared Show Console controller. Vendor pages provide a fixed configuration:
 *
 *   GPUConsole.mount({
 *     actionUrl: './console.cgi',
 *     consoleUrl: './console/',
 *     title: 'AMDGPU Console'
 *   });
 *
 * The module intentionally knows nothing about the GPU command. The CGI is
 * responsible for authentication and the fixed vendor profile.
 */
(function (global) {
  'use strict';
  function escapeText(value) {
    var node = document.createElement('span');
    node.textContent = value || '';
    return node.innerHTML;
  }
  function mount(options) {
    options = options || {};
    var actionUrl = options.actionUrl;
    var consoleUrl = options.consoleUrl;
    var title = options.title || 'GPU Console';
    if (!actionUrl || !consoleUrl) throw new Error('GPU console URLs are required');
    var root = document.createElement('section');
    root.className = 'gpu-console-panel';
    root.innerHTML = '<h2>' + escapeText(title) + '</h2>' +
      '<div class="gpu-console-placeholder">Enable <strong>Show Console</strong> to start the console.</div>' +
      '<iframe class="gpu-console-frame gpu-console-hidden" title="' + escapeText(title) + '"></iframe>' +
      '<div class="gpu-console-error gpu-console-hidden"></div>';
    var toggle = document.createElement('label');
    toggle.className = 'gpu-console-toggle';
    toggle.innerHTML = '<input type="checkbox"> Show Console';
    var checkbox = toggle.querySelector('input');
    var placeholder = root.querySelector('.gpu-console-placeholder');
    var frame = root.querySelector('.gpu-console-frame');
    var error = root.querySelector('.gpu-console-error');
    var synoTokenPromise;
    function getSynoToken() {
      if (!synoTokenPromise) {
        synoTokenPromise = fetch('/webman/login.cgi', { credentials: 'same-origin' })
          .then(function (response) { return response.json(); })
          .then(function (data) { return data.SynoToken || ''; })
          .catch(function () { return ''; });
      }
      return synoTokenPromise;
    }
    function showError(message) { error.textContent = message; error.classList.remove('gpu-console-hidden'); }
    function clearError() { error.textContent = ''; error.classList.add('gpu-console-hidden'); }
    function request(action) {
      return getSynoToken().then(function (token) {
        return fetch(actionUrl + '?action=' + encodeURIComponent(action), {
          cache:'no-store', credentials:'same-origin',
          headers: token ? { 'X-SYNO-TOKEN': token } : {}
        });
      }).then(function (response) { return response.json(); });
    }
    checkbox.addEventListener('change', function () {
      var enabled = checkbox.checked;
      clearError();
      request(enabled ? 'start' : 'stop').then(function (result) {
        if (!result.success) throw new Error(result.error || 'Console request failed');
        if (enabled) {
          if (!result.url || result.url.indexOf(consoleUrl) !== 0) throw new Error('Console URL is unavailable');
          frame.src = result.url;
          frame.classList.remove('gpu-console-hidden'); placeholder.classList.add('gpu-console-hidden');
        }
        else { frame.removeAttribute('src'); frame.classList.add('gpu-console-hidden'); placeholder.classList.remove('gpu-console-hidden'); }
      }).catch(function (err) { checkbox.checked = false; showError(err.message); });
    });
    if (options.toggleTarget) options.toggleTarget.appendChild(toggle);
    else root.prepend(toggle);
    return { root: root, toggle: toggle, stop: function () { checkbox.checked = false; return request('stop'); } };
  }
  global.GPUConsole = { mount: mount };
}(window));
