import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { mkdtempSync, mkdirSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const script = fileURLToPath(new URL('./native-test-scope.mjs', import.meta.url));

function repository(t) {
	const cwd = mkdtempSync(path.join(tmpdir(), 'swift95-ci-scope-'));
	t.after(() => rmSync(cwd, { recursive: true, force: true }));
	const git = (...args) => execFileSync('git', args, { cwd, encoding: 'utf8' }).trim();
	const write = (file) => {
		mkdirSync(path.dirname(path.join(cwd, file)), { recursive: true });
		writeFileSync(path.join(cwd, file), 'fixture\n');
	};
	git('init', '-q');
	git('config', 'user.name', 'CI scope tests');
	git('config', 'user.email', 'ci-scope@example.invalid');
	const commit = () => { git('add', '.'); git('commit', '-qm', 'fixture', '--allow-empty'); return git('rev-parse', 'HEAD'); };
	const base = commit();
	const scope = (head = 'HEAD', from = base) => execFileSync(process.execPath, [script, from, head], { cwd, encoding: 'utf8' }).trim();
	return { cwd, git, write, commit, base, scope };
}

for (const [file, expected] of [
	['Website/src/styles/swift95.css', 'false'],
	['Documentation/Guide.md', 'false'],
	['Assets/README/preview.png', 'false'],
	['README.md', 'false'],
	['Examples/Slack95/README.md', 'false'],
	['Sources/Swift95/Swift95.docc/Swift95.md', 'false'],
	['Sources/Swift95/Public/Button95.swift', 'true'],
	['Sources/Swift95/Resources/data.md', 'true'],
	['Tests/Swift95Tests/__Snapshots__/Button95.png', 'true'],
	['Catalog/Project.swift', 'true'],
	['Examples/Slack95/Sources/App.swift', 'true'],
	['Package.resolved', 'true'],
	['Makefile', 'true'],
	['.github/workflows/tests.yml', 'true'],
	['NewBuildConfiguration', 'true'],
]) {
	test(`${file} requires native tests: ${expected}`, (t) => {
		const repo = repository(t); repo.write(file); repo.commit();
		assert.equal(repo.scope(), expected);
	});
}

test('deleting or moving a native source into documentation still runs native tests', (t) => {
	const repo = repository(t);
	repo.write('Sources/Example.swift'); const base = repo.commit();
	repo.git('rm', 'Sources/Example.swift'); repo.write('Website/example.swift'); repo.commit();
	assert.equal(repo.scope('HEAD', base), 'true');
});

test('base-only changes do not count as pull request changes', (t) => {
	const repo = repository(t);
	repo.git('checkout', '-qb', 'docs'); repo.write('README.md'); const head = repo.commit();
	repo.git('checkout', '--detach', repo.base); repo.write('Sources/BaseChange.swift'); const base = repo.commit();
	assert.equal(repo.scope(head, base), 'false');
});

test('an invalid comparison fails instead of skipping native tests', (t) => {
	const repo = repository(t);
	assert.notEqual(spawnSync(process.execPath, [script, 'missing', 'HEAD'], { cwd: repo.cwd }).status, 0);
});
