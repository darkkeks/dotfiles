#!/usr/bin/env python3

import os.path
import click
from yandex_tracker_client import TrackerClient
from yandex_tracker_client.exceptions import NotFound
from yandex_tracker_client.objects import Resource
from typing import Optional


TOKEN_PATH = '/Users/darkkeks/.direct-tokens/local_user_oauth_token'
USER_AGENT = 'darkkeks/create-issue.py'


ISSUE_ALIAS = {
    'retargeting': 'DIRECT-176277',
    'chassis': 'DIRECT-186946',
    'unused': 'DIRECT-164934',
}


def create_client() -> TrackerClient:
    with open(TOKEN_PATH, 'r') as f:
        token = f.read().strip()

    return TrackerClient(
            base_url='https://st-api.yandex-team.ru',
            token=token,
            headers={'User-Agent': USER_AGENT})


def get_issue(client: TrackerClient, key: str) -> Optional[Resource]:
    try:
        return client.issues[key]
    except NotFound:
        return None


@click.command()
@click.argument('summary', nargs=-1, required=True)
@click.option('-d', '--description', help='Issue description', required=False)
def chore(summary: list[str], description: Optional[str]):
    summary = [s.strip() for s in summary]
    summary_text = ' '.join(summary)

    description = summary_text + '\n\n----\n\n' + (description or '')

    create_issue(
            queue='CHORE',
            summary=summary_text,
            description=description,
            do=True)


@click.command()
@click.option('-s', '--summary', help='Issue summary', prompt=True)
@click.option('-p', '--parent', help='Parent issue key')
@click.option('-r', '--relates', help='Related issue key', multiple=True)
@click.option('-d', '--description', help='Issue description', required=False)
@click.option('-t', '--tag', help='Issue tags', multiple=True)
@click.option('-c', '--closed', help='Create issue in closed state, with Affected apps: none', is_flag=True)
@click.option('--do', is_flag=True, help='Actually create an issue')
def create(summary: str,
           parent: Optional[str],
           relates: list[str],
           description: Optional[str],
           tag: list[str],
           closed: bool,
           do: bool):
    create_issue(
            queue='DIRECT',
            summary=summary,
            parent=parent,
            relates=relates,
            description=description,
            tag=tag,
            closed=closed,
            do=do)


def create_issue(
        queue: str,
        summary: str,
        parent: Optional[str] = None,
        relates: list[str] = [],
        description: Optional[str] = None,
        tag: list[str] = [],
        closed: bool = False,
        do: bool = False):
    client = create_client()

    parent_issue = None
    if parent is not None:
        if parent in ISSUE_ALIAS:
            parent = ISSUE_ALIAS[parent]

        parent_issue = get_issue(client, parent)
        if parent_issue is None:
            click.secho(f'Issue {parent} could not be found!', fg='red')
            return

    related_issues = []
    for related in relates:
        if related in ISSUE_ALIAS:
            related = ISSUE_ALIAS[related]

        related_issue = get_issue(client, related)
        if related_issue is None:
            click.secho(f'Issue {related} could not be found!', fg='red')
            return

        related_issues.append(related_issue)

    assignee = 'darkkeks'

    if do:
        additional = {}
        if parent:
            additional['parent'] = parent
        if related_issues:
            additional['links'] = [
                dict(
                    issue=related_issue,
                    relationship='relates',
                )
                for related_issue in related_issues
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
    if os.path.basename(__file__) == 'chore':
        chore()

    create()
