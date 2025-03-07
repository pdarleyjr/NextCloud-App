/**
 * SPDX-FileCopyrightText: 2021 Nextcloud GmbH and Nextcloud contributors
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

/**
 * Generate a random hex id to use with vue components.
 *
 * WARNING: This method does not use a secure random generator and isn't suited for
 * cryptographic purposes.
 *
 * @return {string} A random hex id
 */
export function randomId() {
	const array = new Uint32Array(1);
	window.crypto.getRandomValues(array);
	return array[0].toString(16);
}
