import { expect } from 'chai';
import { mount } from 'enzyme';
import React from 'react';
import sinon from 'sinon';

import { hideModal } from '~/actions/modal';
import EditDisk from '~/linodes/linode/settings/advanced/components/EditDisk';

import { changeInput, expectDispatchOrStoreErrors, expectRequest } from '@/common';
import { testLinode1236 } from '@/data/linodes';


describe('linodes/linode/settings/advanced/components/EditDisk', () => {
  const sandbox = sinon.sandbox.create();

  afterEach(() => {
    sandbox.restore();
  });

  const testDisk = testLinode1236._disks.disks[12345];

  it('should dismiss the modal when Cancel is clicked', () => {
    const dispatch = sandbox.spy();
    const modal = mount(
      <EditDisk
        dispatch={dispatch}
        linode={testLinode1236}
        disk={testDisk}
        free={0}
      />);

    modal.find('CancelButton').simulate('click');
    expect(dispatch.callCount).to.equal(1);
    expect(dispatch.calledWith(hideModal())).to.equal(true);
  });

  it('should commit changes to the API', async () => {
    const dispatch = sandbox.spy();
    const modal = mount(
      <EditDisk
        dispatch={dispatch}
        linode={testLinode1236}
        disk={testDisk}
        free={0}
      />);

    changeInput(modal, 'label', 'The label');
    changeInput(modal, 'size', 1000);

    await modal.find('Form').props().onSubmit({ preventDefault() {} });

    expect(dispatch.callCount).to.equal(1);
    await expectDispatchOrStoreErrors(dispatch.firstCall.args[0], [
      ([fn]) => expectRequest(fn, '/linode/instances/1236/disks/12345', {
        method: 'PUT',
        body: { label: 'The label' },
      }),
      ([fn]) => expectRequest(fn, '/linode/instances/1236/disks/12345/resize', {
        method: 'POST',
        body: { size: 1000 },
      }),
    ], 3);
  });
});
