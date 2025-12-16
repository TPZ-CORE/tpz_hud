fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game "rdr3"

author 'Nosmakos'
description 'TPZ-CORE - Metabolism & Leveling HUD'
version '1.0.1'

ui_page('html/index.html')

shared_scripts { 'config.lua', 'locales.lua' }
client_scripts { 'client/*.lua' }

dependencies {
    'tpz_core',
    'tpz_characters',
    'tpz_inventory',
    'tpz_metabolism',
}

files { 'html/**/*' }
