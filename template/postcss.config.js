const CSSFunctions = {
	headings: function self(from = 1, to = 6) {
		if (from == to) {
			return `h#${from}`
		} else {
			return `h#${from},` + self(from + 1, to)
		}
	}
}

module.exports = {
	plugins: [
		require('postcss-functions')({ functions: CSSFunctions }),
		require('postcss-mixins'),
		require('postcss-nested'),
		//// https://github.com/Scrum/postcss-at-rules-variables/issues/204
		// require('postcss-at-rules-variables')({ atRules: ['media', 'mixin'] }),
		//// It doesn't work with `.pcss`:
		//// https://github.com/postcss/postcss-custom-selectors/issues/47
		require('postcss-custom-selectors')({
			importFrom: [
				'assets/styles/lib/_inputs-with-types.pcss'
			],
			exportTo: 'assets/styles/main.pcss'
		}),
		require('postcss-flexbugs-fixes'),
		require('autoprefixer')
	]
}
