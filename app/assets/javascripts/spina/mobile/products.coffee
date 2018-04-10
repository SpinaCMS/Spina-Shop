$(document).on 'click', '#start_scanning', (e) ->
  Quagga.init {
    debug: true,
    inputStream: {
      name: "Live",
      type: "LiveStream",
      target: document.querySelector('#product_scannerz')
    },
    decoder: {
      readers: ["ean_reader"],
      debug: {
        drawBoundingBox: true,
        showFrequency: true,
        drawScanline: true,
        showPattern: true
      }
    }
  }, (error) ->
    # If there's an error, simply log it and return
    if error
      console.log(error)
      return

    Quagga.start()
    Quagga.onDetected (data) ->
      $('#product_scanner').val(data.codeResult.code)
