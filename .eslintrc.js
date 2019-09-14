module.exports = {
  extends: 'airbnb-base',
  env: {
    node: true,
  },
  rules: {
    'arrow-body-style': 'off',
    'max-len': [2, 120, 4],
    'no-console': 'off',
    'no-param-reassign': ['error', { props: false }],
  },
};