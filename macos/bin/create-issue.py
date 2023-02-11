#!/usr/local/bin/python3

import click
from startrek_client import Startrek
from startrek_client.exceptions import NotFound
from startrek_client.objects import Resource
from typing import Optional


TOKEN_PATH = '/Users/darkkeks/.direct-tokens/local_user_oauth_token'
USER_AGENT = 'darkkeks/create-issue.py'


ISSUE_ALIAS = {
    'retargeting': 'DIRECT-176277',
    'chassis': 'DIRECT-186946',
}


def create_client() -> Startrek:
    with open(TOKEN_PATH, 'r') as f:
        token = f.read().strip()

    return Startrek(token=token, useragent=USER_AGENT)


def get_issue(client: Startrek, key: str) -> Optional[Resource]:
    try:
        return client.issues[key]
    except NotFound:
        return None


@click.command()
@click.option('-p', '--parent', help='Parent issue key')
@click.option('-r', '--relates', help='Related issue key')
@click.option('-s', '--summary', help='Issue summary', prompt=True)
@click.option('-d', '--description', help='Issue description', required=False)
@click.option('-t', '--tag', help='Issue tags', multiple=True)
@click.option('-c', '--closed', help='Create issue in closed state, with Affected apps: none', is_flag=True)
@click.option('--do', is_flag=True, help='Actually create an issue')
def create_issue(
        parent: Optional[str],
        relates: Optional[str],
        summary: str,
        description: Optional[str],
        tag: list[str],
        closed: bool,
        do: bool):
    client = create_client()

    parent_issue = None
    if parent is not None:
        if parent in ISSUE_ALIAS:
            parent = ISSUE_ALIAS[parent]

        parent_issue = get_issue(client, parent)
        if parent_issue is None:
            click.secho(f'Issue {parent} could not be found!', fg='red')
            return

    if relates is not None:
        if relates in ISSUE_ALIAS:
            relates = ISSUE_ALIAS[relates]

        relates_issue = get_issue(client, relates)
        if relates_issue is None:
            click.secho(f'Issue {relates} could not be found!', fg='red')
            return

    queue = 'DIRECT'
    assignee = 'darkkeks'

    if do:
        additional = {}
        if parent:
            additional['parent'] = parent
        if relates:
            additional['links'] = [
                dict(
                    issue=relates,
                    relationship='relates',
                ),
            ]
        if description:
            additional['description'] = description
        issue = client.issues.create(
            queue=queue, 
            assignee=assignee,
            summary=summary, 
            tags=tag,
            **additional,
        )

        click.secho(f'{issue.key}: {issue.summary}', fg='green')
        click.secho(f'https://st.yandex-team.ru/{issue.key}')

        if closed:
            issue.transitions['close'].execute(
                resolution='fixed',
                affectedApps='none',
            )
    else:
        click.secho(f'Queue: {queue}')
        click.secho(f'Assignee: {assignee}')
        click.secho(f'Summary: {summary}')
        if parent:
            click.secho(f'Parent: {parent}')
        if relates:
            click.secho(f'Relates: {relates}')
        if tag:
            click.secho(f'Tags: ' + ', '.join(tag))
        if description:
            click.secho(f'Description: {description}')

        click.secho('Run with --do to create', fg='yellow')


if __name__ == '__main__':
    create_issue()
