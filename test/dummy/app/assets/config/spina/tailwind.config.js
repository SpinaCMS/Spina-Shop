module.exports = {
  content: [
    '/Users/bram/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/spina-2.17.0/app/views/**/*.*',
'/Users/bram/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/spina-2.17.0/app/components/**/*.*',
'/Users/bram/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/spina-2.17.0/app/helpers/**/*.*',
'/Users/bram/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/spina-2.17.0/app/assets/javascripts/**/*.js',
'/Users/bram/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/spina-2.17.0/app/**/application.tailwind.css'
  ],
  theme: {
    fontFamily: {
      body: ['Metropolis'],
      mono: ['ui-monospace', 'SFMono-Regular', 'Menlo', 'Monaco', 'Consolas', "Liberation Mono", "Courier New", 'monospace']
    },
    extend: {
      colors: {
        spina: {
          light: '#797ab8',
          DEFAULT: '#6865b4',
          dark: '#3a3a70'
        }
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
	require('@tailwindcss/aspect-ratio'),
	require('@tailwindcss/typography')
  ]
}
