/**
 * SPDX-FileCopyrightText: 2021 Nextcloud GmbH and Nextcloud contributors
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import { getRequestToken } from '@nextcloud/auth'
import { loadState } from '@nextcloud/initial-state'
import { linkTo } from '@nextcloud/router'
import { translate, translatePlural } from '@nextcloud/l10n'
import Vue from 'vue'

import Confirmation from '../views/Appointments/Confirmation.vue'

// CSP config for webpack dynamic chunk loading
// eslint-disable-next-line
__webpack_nonce__ = btoa(getRequestToken())

// Correct the root of the app for chunk loading
// OC.linkTo matches the apps folders
// OC.generateUrl ensure the index.php (or not)
// We do not want the index.php since we're loading files
// eslint-disable-next-line
__webpack_public_path__ = linkTo('calendar', 'js/')

Vue.prototype.$t = translate
Vue.prototype.$n = translatePlural

const booking = loadState('calendar', 'booking')

export default new Vue({
	el: '#appointment-confirmation',
	render: h => h(Confirmation, {
		props: {
			booking,
		},
	}),
})
