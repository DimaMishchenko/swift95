import { execFileSync } from 'node:child_process';

const [base, head] = process.argv.slice(2);
if (!base || !head) throw new Error('Expected base and head revisions.');

const paths = execFileSync('git', ['diff', '--name-only', '--no-renames', '-z', `${base}...${head}`])
	.toString('utf8').split('\0').filter(Boolean);
const documentationPrefixes = ['Website/', 'Documentation/', 'Assets/README/'];
const native = paths.some((path) => {
	if (documentationPrefixes.some((prefix) => path.startsWith(prefix))) return false;
	if (/^Sources\/[^/]+\/[^/]+\.docc\//.test(path)) return false;
	if (/^[^/]+\.md$/.test(path) || path === 'LICENSE') return false;
	if (/^(Catalog|Examples(?:\/[^/]+)?)\/README\.md$/.test(path)) return false;
	return true;
});

console.log(native);
