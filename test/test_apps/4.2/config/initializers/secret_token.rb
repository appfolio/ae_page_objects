# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
TestApp::Application.config.secret_key_base = '3b3bfb0dd3b5a41982691b6dca1a114ee2026fc70cfa1e773613aff2ed4271b36e066067a4d97a49330620c40d7069458eee559b43f8b2de8e1604a36fa4f7a2'
TestApp::Application.config.secret_token = '11e07bbab31134df2f2e561e41a6ebfdcd0c060cefe35b34d376b196572150adda846eb3de1242878dd2d34aa1d2d12ae3c93185516d6722b7ce4342ed16334d'
